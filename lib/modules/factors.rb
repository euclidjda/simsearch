class Factors

  # TODO: NEW FACTORS
  # Current Ratio, Quick Ratio, Revenue Growth 1 Year

  @@FactorKeys = [
                  ['Earnings Yield (EBIT)',:ey],
                  ['Price to Earnings',:pe],
                  ['Price to Book',:pb],
                  ['Dividend Yield',:divy],
                  ['Return On Capital (EBIT)',:roc],
                  ['Return On Equity (EBIT)',:roe],
                  ['Return On Assets (EBIT)',:roa],
                  ['Gross Margin',:gmar],
                  ['Operating Margin',:omar],
                  ['Net Margin',:nmar],
                  ['Revenue Growth (4yr)',:grwth],
                  ['EPS Growth Consist. (10yr)',:epscon],
                  ['Debt to Equity',:de],
                  ['Equity to Assets',:ae],
                  ['Price Momentum (1mo)',:mom1],
                  ['Price Momentum (3mo)',:mom3],
                  ['Price Momentum (6mo)',:mom6],
                  ['Price Momentum (9mo)',:mom9],
                  ['Price Momentum (1yr)',:mom12],
                 ]

  @@IntrinsicWeight = {
    :ey     => 31.0 ,
    :pe     => 0.01 ,
    :pb     => 0.02 ,
    :divy   => 33.3 ,
    :roe    => 0.42 ,
    :roa    => 10.5 ,
    :roc    =>  6.5 ,
    :gmar   =>  4.3 ,
    :omar   =>  6.8 ,
    :nmar   =>  6.8 ,
    :grwth  =>  3.9 ,
    :epscon =>  1.8 ,
    :de     => 0.06 ,
    :ae     =>  4.5 ,
    :mom1   => 15.1 ,
    :mom3   =>  8.1 ,
    :mom6   =>  5.3 ,
    :mom9   =>  3.7 ,
    :mom12  =>  3.8 
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
