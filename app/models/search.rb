class Search < ActiveRecord::Base
  attr_accessible :cid, :fromdate, :pricedate, :sid, :thrudate, :type_id, :mean, :count, :wins, :min, :max

  def self.exec(_args)

    _target = _args[:target]
    _epochs = _args[:epochs]
    _type   = _args[:search_type]
    _limit  = _args[:limit]
    _async  = _args[:async]

    cid       = _target.cid
    sid       = _target.sid

    pricedate = _target.get_field('pricedate')
    fromdate  = _epochs[-1].fromdate
    thrudate  = _epochs[ 0].thrudate

    puts "******** search: fromdate = #{fromdate} thrudate = #{thrudate}"

    search = Search.where( :cid       => cid       ,
                           :sid       => sid       ,
                           :pricedate => pricedate ,
                           :fromdate  => fromdate  ,
                           :thrudate  => thrudate  ,
                           :type_id   => _type.id  ).first

    if search.nil?

      # if search has not been run, then we need to execute it
      search = Search.create( :cid       => cid       ,
                              :sid       => sid       ,
                              :pricedate => pricedate ,
                              :fromdate  => fromdate  ,
                              :thrudate  => thrudate  ,
                              :type_id   => _type.id  )

      _epochs.each { |ep|

        status = SearchStatus.find_or_create( :search_id => search.id  ,
                                              :fromdate  => ep.fromdate,
                                              :thrudate  => ep.thrudate)

        status.comment    = "Starting "
        status.num_steps  = nil
        status.cur_step   = nil
        status.complete   = false
        status.save()

        # This call to delay causes create_search_detail to be run ansyncronously
        # by the delayed_job package. For the method to execute, the program
        # "rake jobs:work" must be running in the background.

        if ( _async )
          search.delay.create_search_details(ep)
        else
          search.create_search_details(ep)
        end

      }

    end

    return search

  end

  def create_search_details(_epoch)

    puts "********************* STARTING SEARCH DETAIL FOR #{_epoch.fromdate}"

    limit = 10

    status = SearchStatus.where( :search_id => self.id         ,
                                 :fromdate  => _epoch.fromdate ,
                                 :thrudate  => _epoch.thrudate ).first

    target = SecuritySnapshot::get_snapshot(self.cid,self.sid,self.pricedate)

    search_type = SearchType.where( :id => self.type_id ).first

    factor_keys = search_type.factor_keys()
    weights     = search_type.weight_array()

    fromdate = nil
    thrudate = _epoch.fromdate-1

    candidates = Array::new()

    batch_size = 356 # batch size is in days (not records)

    # create mysql connection. no need for pooling here.
    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]

    # puts "********** host=#{host} database=#{database} " +
    #  "username=#{username} password=#{password}"

    client = Mysql2::Client.new(:host     => host     ,
                                :database => database ,
                                :username => username ,
                                :password => password )

    while (1) do

      fromdate = thrudate + 1
      thrudate = thrudate + batch_size

      thrudate = _epoch.thrudate if ((thrudate <=> _epoch.thrudate) == 1)

      logger.debug "***** fromdate=#{fromdate} thrudate=#{thrudate}"

      sqlstr = target.get_match_sql(search_type, fromdate, thrudate)

      logger.debug sqlstr

      results = client.query(sqlstr, :stream=>true, :cache_rows=>false)

      status.comment = sprintf("Processing year %d (%d records)",
                               fromdate.year,results.count)
      status.save()

      results.each { |row|

        match = SecuritySnapshot::new( row )

        dist = target.distance( match, factor_keys, weights )

        next if (dist < 0)

        candidates.push( { :cid       => match.get_field('cid'),
                           :sid       => match.get_field('sid'),
                           :pricedate => match.get_field('pricedate'),
                           :distance  => dist  } )

      }

      break if (thrudate == _epoch.thrudate)

    end

    # we can close client here
    client.close()

    # debug info line here to make sure we are rendering the right number on screen.
    puts "********** sql_result_size = #{candidates.length}   ***********"

    status.comment = "Processing #{candidates.length} candidate comps."
    status.save()

    comps = consolidate_results( candidates, limit )

    candidates = nil

    comps.each { |c|

      SearchDetail::create( :search_id => self.id       ,
                            :cid       => c[:cid]       ,
                            :sid       => c[:sid]       ,
                            :pricedate => c[:pricedate] ,
                            :dist      => c[:distance]  ,
                            :stk_rtn   => c[:stk_rtn]   ,
                            :mrk_rtn   => c[:mrk_rtn]   )
    }

    status.comment  = "Done."
    status.complete = true
    status.save()

    calculate_summary()

    puts "*********** SEARCH IS DONE"

  end

  def consolidate_results( _candidates, _limit )

    cid_touched = Hash::new()

    SearchDetail.where( :search_id => self.id ).each { |d|

      cid_touched[d.cid] = 1

    }

    _candidates.sort! { |a,b| a[:distance] <=> b[:distance] }

    comps_array = Array::new()

    _candidates.each { |item|

      cid = item[:cid]

      # only return limit number matches
      break if (comps_array.length >= _limit)
      next if cid_touched.has_key?(cid)

      comps_array.push(item)

      cid_touched[cid] = 1

    }

    # Now we need to calcuate the 1 year return and market return for
    # each comparable

    comps_array.each { |comp|

      prices = ExPrice::find_by_range(comp[:cid],
                                      comp[:sid],
                                      comp[:pricedate].to_s,
                                      (comp[:pricedate]+365).to_s)

      first = prices.first
      last  = prices.last

      stk_price0 = first.price / first.ajex #adjust for splits
      stk_price1 = last.price / last.ajex # adjust for splits
      mrk_price0 = first.mrk_price
      mrk_price1 = last.mrk_price

      comp[:stk_rtn] = 100 * (stk_price1/stk_price0 - 1)

      # TODO: JDA: Need to fix this so that market price never
      # returns nil. We need to make market prices daily in ex_update
      if !mrk_price0.nil? && !mrk_price1.nil?
        comp[:mrk_rtn] = 100 * (mrk_price1/mrk_price0 - 1)
      else
        comp[:mrk_rtn] = 0
      end

    }

    # make result size no greater than limit
    return comps_array

  end

  def calculate_summary

   search_details = SearchDetail.where( :search_id => self.id )

    perfs = Array::new()
    weight_sum = 0.0
    values_sum = 0.0

    win_count = 0
    tot_count = 0

    best    = nil
    worst   = nil

    search_details.each { |detail|

      next unless detail.dist > 0

      weight = Math.exp( -detail.dist )

      outperformance = detail.stk_rtn - detail.mrk_rtn

      tot_count += 1
      win_count += 1 if outperformance >= 0

      values_sum += weight * outperformance
      weight_sum += weight

      best  = outperformance if (best.nil?  || outperformance >= best)
      worst = outperformance if (worst.nil? || outperformance <= worst)
    }

    self.with_lock do

      self.mean  = (weight_sum  > 0) ? (values_sum / weight_sum ) : nil
      self.count = tot_count
      self.wins  = win_count
      self.min   = worst
      self.max   = best
      self.save

    end

  end

end
