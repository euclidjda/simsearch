class Search < ActiveRecord::Base
  attr_accessible :cid, :fromdate, :pricedate, :sid, :thrudate, :type_id

  def self.exec(_args)

    _target = _args[:target]
    _epochs = _args[:epochs]
    _type   = _args[:search_type]
    _limit  = _args[:limit]

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

        status.comment    = "Started"
        status.num_steps  = nil
        status.cur_step   = nil
        status.complete   = false
        status.save()

      }

      # This call to delay causes create_search_detail to be run ansyncronously
      # by the delayed_job package. For the method to execute, the program
      # "rake jobs:work" must be running in the background.

      search.delay.create_search_details(_epochs)

    end

    return search

  end

  def create_search_details(_epochs)

    limit = 10

    target = SecuritySnapshot::get_snapshot(self.cid,self.sid,self.pricedate)

    # TODO: all of the following needs validation
    target_ind = target.get_field('idxind')
    target_new = target.get_field('idxnew')

    price = target.get_field('price')  ? Float(target.get_field('price'))      : nil
    csho  = target.get_field('csho')   ? Float(target.get_field('csho'))       : nil
    eps   = target.get_field('epspxq') ? Float(target.get_field('epspxq_ttm')) : nil

    target_cap =
      target.get_field('mrkcap') ? Float(target.get_field('mrkcap')).round() : nil

    cur_epoch = _epochs.shift

    status = SearchStatus.where( :search_id => self.id            ,
                                 :fromdate  => cur_epoch.fromdate ,
                                 :thrudate  => cur_epoch.thrudate ).first

    fromdate = nil
    thrudate = cur_epoch.fromdate-1

    candidates = Array::new()

    batch_size = 366 # batch size is in days (not records)

    # create mysql connection. no need for pooling here.
    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]

    puts "********** host=#{host} database=#{database} " +
      "username=#{username} password=#{password}"

    client = Mysql2::Client.new(:host     => host       ,
                                :database => database   ,
                                :username => username   ,
                                :password => password   )

    while (1) do

      fromdate = thrudate + 1
      thrudate = thrudate + batch_size

      thrudate = cur_epoch.thrudate if ((thrudate <=> cur_epoch.thrudate) == 1)

      status.comment = sprintf("Processing year %d",fromdate.year)
      status.save()

      puts "***** fromdate=#{fromdate} thrudate=#{thrudate}"

      sqlstr = SecuritySnapshot::get_match_sql(target.cid ,
                                               target_ind ,
                                               target_new ,
                                               target_cap ,
                                               fromdate   ,
                                               thrudate   )
      results = client.query(sqlstr, :stream=>true, :cache_rows=>false)

      results.each { |row|

        match = SecuritySnapshot::new( row )

        dist = target.distance( match )

        next if (dist < 0)

        candidates.push( { :cid       => match.get_field('cid'),
                           :sid       => match.get_field('sid'),
                           :pricedate => match.get_field('pricedate'),
                           :distance  => dist  } )

      }

      break if (thrudate == cur_epoch.thrudate)

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

    if (!_epochs.empty?)

      puts "*********** SEARCH NEXT EPOCH"
      create_search_details(_epochs)

    end

    puts "*********** SEARCH IS DONE"

  end

  def consolidate_results( _candidates, _limit )

    if @cid_touched.nil?
      @cid_touched = Hash::new()
    end

    _candidates.sort! { |a,b| a[:distance] <=> b[:distance] }

    comps_array = Array::new()

    _candidates.each { |item|

      cid = item[:cid]

      # only return limit number matches
      break if (comps_array.length >= _limit)
      next if @cid_touched.has_key?(cid)

      comps_array.push(item)

      @cid_touched[cid] = 1

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

end
