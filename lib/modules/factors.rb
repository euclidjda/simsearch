class Factors

  @@FactorKeys = [
               ['Earnings Yield',:ey],
               ['Return On Capital',:roc],
               ['Revenue Growth (4yr)',:grwth],
               ['EPS Growth Consist. (10yr)',:epscon],
               ['Equity/Assets',:ae],
               ['Price Momentum (6mo)',:mom]
              ]

  @@Defaults = [:ey,:roc,:grwth,:epscon,:ae,:mom]

  @@DefaultWeights = [5,5,5,5,5,5]

  def self.all
    return @@FactorKeys
  end

  def self.defaults
    return @@Defaults
  end

  def self.default_weights
    return @@DefaultWeights
  end

end
