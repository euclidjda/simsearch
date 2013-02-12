class Search < ActiveRecord::Base
  attr_accessible :cid, :fromdate, :pricedate, :sid, :thrudate, :search_type

  def self.exec(_args)

    _target    = _args[:target]
    _fromdate  = _args[:fromdate]
    _thrudate  = _args[:thrudate]
    _type      = _args[:search_type]
    _limit     = _args[:limit]

    cid = _target.cid
    sid = _target.sid
    pricedate = _target.datadate

    search = Search.where( :cid         => cid       ,
                           :sid         => sid       ,
                           :pricedate   => pricedate ,
                           :fromdate    => _fromdate ,
                           :thrudate    => _thrudate ,
                           :search_type => _type     ).first
    

    if search.nil?

      # if search has not been run, then we need to execute it
      search = Search.create( :cid         => cid       ,
                              :sid         => sid       ,
                              :pricedate   => pricedate ,
                              :fromdate    => _fromdate ,
                              :thrudate    => _thrudate ,
                              :search_type => _type     )

      
      _target.get_matches(_fromdate,
                          _thrudate,
                          search.id,
                          _limit,
                          method(:search_callback)

      search.execute(_target,_limit)

    end

    return search

  end

  def search_callback(_result_hash)

    logger.debug "***** #{cid} #{sid} #{pricedate} #{fromdate} #{thrudate} "

    _target = _result_hash[:target]
    _rows   = _result_hash[:result_rows]

    candidates = Array::new()

    _rows.each { |row|
      
      match = Factors::new(row)

      dist = _target.distance( match )
      next if (dist < 0)
      candidates.push( { :match => match, :dist => dist } )

    }

    comps = consolidate_results( candidates, _limit )
    
    comps.each { |c|

      ccid  = c['cid']
      csid  = c['sid']
      cdate = c['pricedate']
      cdist = c['distance']

      logger.debug "****** #{self.id} #{ccid} #{csid} #{cdate} #{cdist}"

      SearchDetail::create( :search_id => self.id ,
                            :cid       => ccid     ,
                            :sid       => csid     ,
                            :pricedate => cdate    ,
                            :dist      => cdist    )
      
    }

  end

  def consolidate_results( _candidates, _limit )

    # debug info line here to make sure we are rendering the right number on screen.
    # puts "********** #{distances.length}   ***********"
    # We are guaranteed to have more than one distance in the array here. Sort it.
    _candidates.sort! { |a,b| a[:dist] <=> b[:dist] }
    
    comps_array = Array::new()
    cid_touched = Hash::new()
    
    _candidates.each { |item|
      
      cid = item[:match].cid
      
      # only return limit number matches
      break if (comps_array.length >= _limit)
      next if cid_touched.has_key?(cid)
      
      fields = item[:match].fields()
      fields['distance'] = item[:dist]
      
      comps_array.push(fields)
      
      cid_touched[cid] = 1
    }
    
    # Now we need to calcuate the 1 year return and market return for
    # each comparable
    
    comps_array.each { |comp|
      
      prices = ExPrice::find_by_range(comp['cid'],
                                      comp['sid'],
                                      comp['pricedate'].to_s,
                                      (comp['pricedate']+365).to_s)
      
      first = prices.first
      last  = prices.last
      
      stk_price0 = first.price / first.ajex #adjust for splits
      stk_price1 = last.price / last.ajex # adjust for splits
      mrk_price0 = first.mrk_price
      mrk_price1 = last.mrk_price
      
      comp['stk_rtn'] = 100 * (stk_price1/stk_price0 - 1)
      
      # TODO: JDA: Need to fix this so that market price never
      # returns nil. We need to make market prices daily in ex_update
      if !mrk_price0.nil? && !mrk_price1.nil?
        comp['mrk_rtn'] = 100 * (mrk_price1/mrk_price0 - 1)
      else
        comp['mrk_rtn'] = 0
      end
      
    }
    
    # make result size no greater than limit
    return comps_array
    
  end

end
