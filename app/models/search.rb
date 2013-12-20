class Search < ActiveRecord::Base
  attr_accessible :cid, :fromdate, :pricedate, :sid, :thrudate, :type_id, :mean, :count, :wins, :min, :max
  attr_accessor :ticker; # non-db attribute just used for web server and client.

  def helpers
    ActionController::Base.helpers
  end

  def self.exec(_args)

    _target = _args[:target]
    _epochs = _args[:epochs]
    _type   = _args[:search_type]
    _limit  = _args[:limit]
    _async  = _args[:async]
    _current_user = _args[:current_user]

    cid       = _target.cid
    sid       = _target.sid

    pricedate = _target.get_field('pricedate')
    fromdate  = _epochs[-1].fromdate
    thrudate  = _epochs[ 0].thrudate

    logger.debug "****"
    logstr = sprintf("**** Executing search: %s %s %s %s %s %s",
                     _target.get_field('name'),
                     _target.get_field('ticker'),
                     cid,sid,fromdate,thrudate);
    logger.debug logstr

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

      if ( _async )

        search.delay.create_search_details(_epochs)

      else

        _epochs.each { |ep| search.create_search_details(ep) }

      end


    end

    # With the search at hand, create or update a search action for creation.

    if _current_user
      search_action = SearchAction.find_or_create(:user_id => _current_user.id,
                                                  :search_id => search.id,
                                                  :action_id => SearchActionTypes::Create)
      if search_action.action_count
        search_action.action_count += 1;
      else
        search_action.action_count = 1;
      end

      search_action.touch()

      # Even if we found an existing one, to update the timestamp, do a save.
      search_action.save()
    end

    return search

  end

  def create_search_details(_epochs)

    cur_epoch = (_epochs.is_a? Array) ? _epochs.shift : _epochs

    status = SearchStatus.create( :search_id => self.id            ,
                                  :fromdate  => cur_epoch.fromdate ,
                                  :thrudate  => cur_epoch.thrudate )
    status.comment    = "Starting deep historical search for similar companies.."
    status.num_steps  = nil
    status.cur_step   = nil
    status.complete   = false
    status.save()

    # TODO: RETURN HERE IF SEARCH HAS ALREADY STARTED

    logger.debug "**** Executing search detail for epoch #{cur_epoch.fromdate} to #{cur_epoch.thrudate}"

    limit = 8

    target = SecuritySnapshot::get_snapshot(self.cid,self.sid,self.pricedate)

    search_type = SearchType.where( :id => self.type_id ).first

    factor_keys = Array::new()
    weights     = Array::new()

    search_type.factor_keys().each_with_index do |factor_key,index|

      if (!target.get_factor(factor_key).nil?) 

        factor_keys.push( factor_key );
        weights.push( search_type.weight_array()[index] );

      end
      
    end

    # normalize weights
    weight_sum = weights.inject{ |sum,n| sum + n }
    weights.map! { |w| w / weight_sum } if (weight_sum > 0)

    # create mysql connection. no need for pooling here.
    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]

    # logger.debug "********** host=#{host} database=#{database} " +
    #  "username=#{username} password=#{password}"

    client = Mysql2::Client.new(:host     => host     ,
                                :database => database ,
                                :username => username ,
                                :password => password )

    fromdate = nil
    thrudate = cur_epoch.fromdate-1

    candidates = Array::new()

    batch_size = 365 # batch size is in days (not records)

    # determine gicslevel
    gics_types = ['sub','ind','grp','sec']
    gicstype_index = gics_types.index( search_type.gicslevel )
    company_count = 0

    while ( gicstype_index < gics_types.length-1 ) do

      status.comment = "Narrowing search to likely candidates.."
      status.save()

      logger.debug status.comment

      sqlstr = target.get_match_count_sql(search_type,cur_epoch.fromdate,cur_epoch.thrudate)
      logger.debug sqlstr
      results_count = client.query(sqlstr)
      company_count = results_count.first["company_count"]

      break if (company_count > 20)

      gicstype_index += 1
      search_type.gicslevel = gics_types[gicstype_index]

    end

    while (1) do

      fromdate = thrudate + 1
      thrudate = thrudate + batch_size

      thrudate = cur_epoch.thrudate if ((thrudate <=> cur_epoch.thrudate) == 1)

      sqlstr = target.get_match_sql(search_type, fromdate, thrudate)

      logger.debug sqlstr

      results = client.query(sqlstr, :cache_rows=>false)

      status.comment = "Searching year #{fromdate.year} and evaluating 
                        #{helpers.number_with_delimiter(results.count)} point-in-time records..";
      status.save()

      results.each { |row|

        match = SecuritySnapshot::new( row )

        dist = target.distance( match, factor_keys, weights )

        next if (dist.nil? || dist < 0)

        candidates.push( { :cid       => match.get_field('cid'),
                           :sid       => match.get_field('sid'),
                           :pricedate => match.get_field('pricedate'),
                           :distance  => dist  } )

      }

      break if (thrudate == cur_epoch.thrudate)

    end

    # we can close client here
    client.close()

    status.comment = "Processing #{helpers.number_with_delimiter(candidates.length)} 
                      candidate comparables.."
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

    # QUEUE UP NEXT EPOCH
    if ((_epochs.is_a? Array) && !_epochs.empty?)
      self.delay.create_search_details(_epochs)
    else
      logger.debug "**** Search is done."
    end

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

      if (prices.length > 0)

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

        else

        logger.debug "**** Bad price data for #{cid} #{sid} #{pricedate}"

        # This should never really happen
          comp[:stk_rtn] = 0
          comp[:mrk_rtn] = 0

        end

    }

    # make result size no greater than limit
    return comps_array

  end

  def calculate_summary

   search_details = SearchDetail.where( :search_id => self.id )

    perfs = Array::new()
    under_sum = 0.0
    over_sum  = 0.0

    win_count = 0
    tot_count = 0

    best    = nil
    worst   = nil

    search_details.each { |detail|

      outperformance = detail.stk_rtn - detail.mrk_rtn

      tot_count += 1

      if (outperformance >= 0)
        over_sum  += outperformance
        win_count += 1
      else
        under_sum += outperformance
      end

      best  = outperformance if (best.nil?  || outperformance >= best)
      worst = outperformance if (worst.nil? || outperformance <= worst)

    }

    self.with_lock do

      self.count = tot_count
      self.wins  = win_count
      self.min   = worst
      self.max   = best

      los_count = tot_count - win_count

      self.mean       = tot_count > 0 ? (over_sum + under_sum) / tot_count : nil;
      self.mean_over  = win_count > 0 ? over_sum / win_count : nil
      self.mean_under = los_count > 0 ? under_sum / los_count : nil

      self.save

    end

  end

end
