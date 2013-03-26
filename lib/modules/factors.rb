class Factors

  @@FactorKeys = [
               ['Earnings Yield',:ey],
               ['Return On Capital',:roc],
               ['Revenue Growth (4yr)',:grwth],
               ['EPS Growth Consist. (10yr)',:epscon],
               ['Equity/Assets',:ae],
               ['Price Momentum (6mo)',:mom]
              ]

  @@IntrinsicWeight = {
    :ey     => 31.0 ,
    :roc    =>  6.5 ,
    :grwth  =>  3.9 ,
    :epscon =>  1.8 ,
    :ae     => 4.54 ,
    :mom    => 5.26
  }
  
  @@Defaults = [:ey,:roc,:grwth,:epscon,:ae,:mom]

  @@DefaultUserWeights = [5,5,5,5,5,5]

  def self.all
    return @@FactorKeys
  end

  def self.defaults
    return @@Defaults
  end

  def self.default_weights
    return @@DefaultUserWeights
  end

  def self.intrinsic_weight(factor_key)
    return @@IntrinsicWeight[factor_key]
  end

  @@factor_weights = [ 31.0, 6.5, 3.9, 1.8, 4.54, 5.26]

end
