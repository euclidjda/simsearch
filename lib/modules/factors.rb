class Factors

  @@Factors = [
               ['Earnings Yield',:ey],
               ['Return On Capital',:roc],
               ['Revenue Growth (4yr)',:grwth],
               ['EPS Growth Consist. (10yr)',:epscon],
               ['Equity/Assets',:ae],
               ['Price Momentum (6mo)',:mom]
              ]

  @@Defaults = [:ey,:roc,:grwth,:epscon,:ae,:mom]

  @@DefaultWeights = [3,4,5,2,1,8]

  def self.all
    return @@Factors
  end

  def self.defaults
    return @@Defaults
  end

  def self.default_weights
    return @@DefaultWeights
  end

end
