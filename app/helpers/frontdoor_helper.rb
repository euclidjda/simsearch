module FrontdoorHelper

  def display_date_v1( date )
    monthname = Date::MONTHNAMES[date.month][0..2]
    sprintf("%s %02d, %04d",monthname,date.day,date.year)
  end

  def normalized_weights( user_weights ) 

    sum = 0

    user_weights.each { |weight|
      sum += weight
    }

    user_weights.map { |uw| sum > 0 ? uw/sum : 0.0 }

  end

  def load_search_form_params( search_type, session )

    factors = Array::new
    weights = Array::new
    gicslevel = nil
    newflag = nil

    if search_type.nil? && session[:type_id]

      search_type = SearchType.where( :id => session[:type_id] ).first

    end

    if !search_type.nil?

      factors   = search_type.factor_keys
      weights   = search_type.weight_array_as_s
      gicslevel = search_type.gicslevel
      newflag   = search_type.newflag
      
    else
      
      factors   = Factors::defaults
      weights   = Factors::default_weights
      gicslevel = 'ind'
      newflag   = 1
      
    end

    return factors, weights, gicslevel, newflag

  end

end
