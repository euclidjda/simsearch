class Factors

  @@Factors = [
               ['Earnings Yield',:ey],
               ['Return On Capital',:roc],
               ['Revenue Growth (4yr)',:grwth],
               ['EPS Growth Consist. (10yr)',:epscon],
               ['Equity/Assets',:ae],
               ['Price Momentum (6mo)',:momentum]
              ]

  @@Defaults = [:ey,:roc,:grwth,:epscon,:ae,:momentum]

  @@DefaultWeights = [5,5,5,5,5,5]

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
