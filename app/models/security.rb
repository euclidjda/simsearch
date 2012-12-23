class Security < ActiveRecord::Base
  attr_accessible :name, :ticker, :cid, :sid

  def to_s
    "cid:#{cid}, sid:#{sid}, ticker:#{ticker}, name:#{name}"
  end

  def self.find_by_ticker(ticker)
    Security.where(:ticker => ticker).first
  end 

  def get_comparables

    # TODO: JDA: support for querying on specific datadate instead of most recent
    # TODO: JDA: support for filters

    target    = nil
    distances = Array::new()

    # get factors for the stock defined by sid, cid pair
    target = Factors::get( :cid => cid, :sid => sid )

    if !target.nil?
      # The target has no distance from itself. Push as the topmost element.
      distances.push( { :match => target, :dist => 0.0 } )

      # filters are TBD arguments.
      filters = nil

      target.each_match( :filters => filters ) { |match|
        dist = target.distance( match )
        next if (dist < 0)
        distances.push( { :match => match, :dist => dist } )
      }
    else
      return "[{'error': 'No factors found for security cid:#{cid}, sid:#{sid}'}]"
    end # if !target.nil?

    # We are guaranteed to have more than one distance in the array here. Sort it.
    distances.sort! { |a,b| a[:dist] <=> b[:dist] }

    result_obj  = Array::new()
    cid_touched = Hash::new()

    distances.each { |item|

      cid    = item[:match].cid
      # Noisy but informing logging option.
      # puts "cid=#{cid}" 
      
      next if cid_touched.has_key?(cid)

      fields = item[:match].fields
      fields['distance'] = item[:dist]

      result_obj.push(fields)

      cid_touched[cid] = 1
    }

    return result_obj.to_json

  end # get_comparables

end # class Security
