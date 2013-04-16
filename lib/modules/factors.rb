class Factors

  # TODO: NEW FACTORS
  # Current Ratio, Quick Ratio, Revenue Growth 1 Year

  @@FactorAttributes = {
    :ey     => { :order =>   1, :iw =>   31.0, :name => "Earnings Yield"    },
    :pe     => { :order =>  10, :iw =>   0.01, :name => "Price to Earnings" },
    :pb     => { :order =>  20, :iw =>   0.02, :name => "Price to Book"     },
    :divy   => { :order =>  30, :iw =>   33.3, :name => "Dividend Yield"    },
    :roe    => { :order =>  40, :iw =>   0.42, :name => "Return on Equity"  },
    :roa    => { :order =>  50, :iw =>   10.5, :name => "Return on Assets"  },
    :roc    => { :order =>  60, :iw =>    6.5, :name => "Return on Capital" },
    :gmar   => { :order =>  70, :iw =>    4.3, :name => "Gross Margin"      },
    :omar   => { :order =>  80, :iw =>    6.8, :name => "Operating Margin"  },
    :nmar   => { :order =>  90, :iw =>    6.8, :name => "Net Margin"        },
    :grwth  => { :order => 100, :iw =>    3.9, :name => "Revenue Growth (yr)"},
    :epscon => { :order => 110, :iw =>    1.8, :name => "EPS Growth Consist. (10yr)" },
    :de     => { :order => 120, :iw =>   0.06, :name => "Debt to Equity"    },
    :ae     => { :order => 130, :iw =>    4.5, :name => "Assets to Equity"  },
    :mom1   => { :order => 140, :iw =>   15.1, :name => "Price Momentum (1mo)"},
    :mom3   => { :order => 150, :iw =>    8.1, :name => "Price Momentum (3mo)"},
    :mom6   => { :order => 160, :iw =>    5.3, :name => "Price Momentum (6mo)"},
    :mom9   => { :order => 170, :iw =>    3.7, :name => "Price Momentum (9mo)"},
    :mom12  => { :order => 180, :iw =>    3.8, :name => "Price Momentum (12mo)"} 
  }

  @@DefaultUserWeights = [5,5,5,5,5,5]
  
  @@DefaultFactors = [:ey,:roc,:grwth,:epscon,:ae,:mom6]

  def self.all
    return @@FactorKeys
  end

  def self.defaults
    return @@DefaultFactors
  end

  def self.default_weights
    return @@DefaultUserWeights
  end

  def self.intrinsic_weight(factor_key)
    attr = @@FactorAttributes[factor_key]
    return attr.nil? ? nil : attr[:iw]
  end

  def self.factor_name(factor_key)
    attr = @@FactorAttributes[factor_key]
    return attr.nil? ? nil : attr[:name]
  end

  def self.factor_order(factor_key)
    attr = @@FactorAttributes[factor_key]
    return attr.nil? ? nil : attr[:order]
  end

  def self.factor_names_and_keys 

    result = Array::new

    factor_keys = @@FactorAttributes.keys
    factor_keys.sort! { |a,b| factor_order(a) <=> factor_order(b) }

    factor_keys.each { |key|
      
      row = [factor_name(key),key] 
      result.push(row)

    }

    return result

  end

end
