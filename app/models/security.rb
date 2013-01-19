class Security < ActiveRecord::Base
  def to_s
    "cid:#{cid}, sid:#{sid}, ticker:#{ticker}, name:#{name}"
  end

  def self.find_by_ticker(_t)
    Security.where(:ticker => _t).first
  end 

  def self.find_by_cidsid(_c, _s)
    Security.where(:cid => _c, :sid => _s).first
  end

  def get_comparables(args)

    # TODO: JDA: support for filters
    # TODO: JDA: support a result size limit

    # any or all of these can be nil
    _start_date  = args[:start_date].nil? ? '1990-12-31' : args[:start_date]
    _end_date    = args[:end_date].nil? ? '9999-12-31' : args[:end_date]
    _limit       = args[:limit] 

    target     = nil
    distances  = Array::new()

    # get factors for the stock defined by sid, cid pair
    target = Factors::get( cid, sid )

    # FE : we can probably do away with this check and have an assert-like behavior.
    # if we have a security object instance but cannot find factors for it, we have a db problem.
    if !target.nil?
      
      # filters are TBD arguments.
      target.each_match( _start_date, _end_date ) { |match|
        dist = target.distance( match )
        next if (dist < 0)
        distances.push( { :match => match, :dist => dist } )
      }

      # debug info line here to make sure we are rendering the right number on screen.
      puts "********** #{distances.length}   ***********"

      # We are guaranteed to have more than one distance in the array here. Sort it.
      distances.sort! { |a,b| a[:dist] <=> b[:dist] }

      result_array = Array::new()
      cid_touched = Hash::new()

      distances.each { |item|

        cid = item[:match].cid
        
        # only return limit number matches
        break if (!_limit.nil? && (result_array.length >= _limit))
        next if cid_touched.has_key?(cid)

        fields = item[:match].fields()
        fields['distance'] = item[:dist]

        result_array.push(fields)

        cid_touched[cid] = 1
      }

      # make result size no greater than limit
      return result_array
      
    else
      # No factors were found for the target cid/sid pair. 
      return nil

    end # if !target.nil?

  end # get_comparables

end # class Security
