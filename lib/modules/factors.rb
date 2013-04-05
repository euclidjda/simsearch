class Factors

  @@FactorKeys = [
                  ['Earnings Yield',:ey],
                  ['Return On Capital',:roc],
                  ['Gross Margin',:gmar],
                  ['Revenue Growth (4yr)',:grwth],
                  ['EPS Growth Consist. (10yr)',:epscon],
                  ['Equity/Assets',:ae],
                  ['Price Momentum (1mo)',:mom1],
                  ['Price Momentum (3mo)',:mom3],
                  ['Price Momentum (6mo)',:mom6],
                  ['Price Momentum (9mo)',:mom9],
                  ['Price Momentum (1yr)',:mom12],
                 ]

  @@IntrinsicWeight = {
    :ey     => 31.0 ,
    :roc    =>  6.5 ,
    :gmar   =>  4.0 ,
    :grwth  =>  3.9 ,
    :epscon =>  1.8 ,
    :ae     => 4.54 ,
    :mom1   => 5.26 ,
    :mom3   => 5.26 ,
    :mom6   => 5.26 ,
    :mom9   => 5.26 ,
    :mom12  => 5.26 
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
    return @@IntrinsicWeight[factor_key]
  end

end
