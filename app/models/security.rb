class Security < ActiveRecord::Base
  def to_s
    "cid:#{cid}, sid:#{sid}, ticker:#{ticker}, name:#{name}"
  end

  def self.find_by_ticker(t)
    Security.where(:ticker => t).first
  end 

  def self.find_by_cidsid(c, s)
    Security.where(:cid => c, :sid => s).first
  end

  def get_comparables(args)

    # TODO: JDA: support for filters
    # TODO: JDA: support a result size limit

    # any or all of these can be nil
    start_date  = args[:start_date].nil? ? '1990-12-31' : args[:start_date]
    end_date    = args[:end_date].nil? ? '9999-12-31' : args[:end_date]
    limit       = args[:limit] 

    target     = nil
    distances  = Array::new()
    result_obj = Object::new()

    # get factors for the stock defined by sid, cid pair
    target = Factors::get( :cid => cid, :sid => sid )

    #
    # TODO: FE: remove later. Just placing here to show that we can access
    #           all table columns as members directly from this model.
    puts "****  #{cid} #{sid} #{secstat} **** "
    #
    #

    if !target.nil?
      # The target has no distance from itself. Push as the topmost element.
      distances.push( { :match => target, :dist => 0.0 } )

      # filters are TBD arguments.
      filters = nil

      target.each_match( :start_date => start_date , 
                         :end_date   => end_date   , 
                         :filters    => filters ) { |match|
        dist = target.distance( match )
        next if (dist < 0)
        distances.push( { :match => match, :dist => dist } )
      }

      # We are guaranteed to have more than one distance in the array here. Sort it.
      distances.sort! { |a,b| a[:dist] <=> b[:dist] }

      result_array  = Array::new()
      cid_touched = Hash::new()

      distances.each { |item|

        cid = item[:match].cid
        # Noisy but informing logging option.
        # puts "cid=#{cid}" 
        
        break if (!limit.nil? && (result_array.length >= limit))
        next if cid_touched.has_key?(cid)

        fields = item[:match].fields
        fields['distance'] = item[:dist]

        result_array.push(fields)

        cid_touched[cid] = 1

      }

      # make result size no greater than limit
      
      return result_array.to_json

    else
      # No factors were found for the target cid/sid pair. 
      return nil

    end # if !target.nil?

  end # get_comparables

end # class Security
