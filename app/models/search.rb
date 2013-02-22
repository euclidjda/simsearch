class Search < ActiveRecord::Base
  attr_accessible :cid, :fromdate, :pricedate, :sid, :thrudate, :search_type, :completed

  def self.exec(_args)

    _target    = _args[:target]
    _fromdate  = _args[:fromdate]
    _thrudate  = _args[:thrudate]
    _type      = _args[:search_type]
    _limit     = _args[:limit]

    cid = _target.cid
    sid = _target.sid
    pricedate = _target.fields['pricedate']

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
                              :search_type => _type     ,
                              :completed   => 0         )


      search.delay.create_search_details(_limit)

    end

    return search

  end

  def create_search_details(_limit)

    target = SecuritySnapshot::get_snapshot(self.cid,self.sid,self.pricedate)
    
    # TODO: all of the following needs validation
    target_ind = target.get_field('idxind')
    target_new = target.get_field('idxnew')
    
    price = target.get_field('price')  ? Float(target.get_field('price'))      : nil
    csho  = target.get_field('csho')   ? Float(target.get_field('csho'))       : nil
    eps   = target.get_field('epspxq') ? Float(target.get_field('epspxq_ttm')) : nil
    
    target_cap = target.get_field('mrkcap') ? Float(target.get_field('mrkcap')).round() : nil
    
    fromdate = self.fromdate
    thrudate = self.fromdate+1000

    candidates = Array::new()

    while (1) do

      logger.debug "***** fromdate=#{fromdate} thrudate=#{thrudate}"

      thrudate = self.thrudate if ((thrudate <=> self.thrudate) == 1)

      sqlstr = SecuritySnapshot::get_match_sql(target.cid,
                                               target_ind,
                                               target_new,
                                               target_cap,
                                               fromdate,
                                               thrudate)
      
      results = nil
      
      ActiveRecord::Base.uncached() {
        
        results = ActiveRecord::Base.connection.select_all(sqlstr) 
        
      }
      
      results.each { |row|
        
        match = SecuritySnapshot::new(row)
        
        dist = target.distance( match )
        
        next if (dist < 0)
        
        candidates.push( { :cid       => match.get_field('cid'), 
                           :sid       => match.get_field('sid'),
                           :pricedate => match.get_field('pricedate'),
                           :distance  => dist  } )
        
      }

      break if (thrudate == self.thrudate)

      fromdate = thrudate+1
      thrudate = thrudate+1000

    end

    # debug info line here to make sure we are rendering the right number on screen.
    logger.debug "********** #{candidates.length}   ***********"

    comps = Search::consolidate_results( candidates, _limit )
    
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

    self.completed = 1
    self.save()

  end

  def self.consolidate_results( _candidates, _limit )

    # debug info line here to make sure we are rendering the right number on screen.
    # puts "********** #{distances.length}   ***********"
    # We are guaranteed to have more than one distance in the array here. Sort it.
    _candidates.sort! { |a,b| a[:distance] <=> b[:distance] }
    
    comps_array = Array::new()
    cid_touched = Hash::new()
    
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

end
