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
    :pe     =>  0.1 ,
    :pb     =>  0.5 ,
    :divy   => 50.0 ,
    :roe    =>  6.5 ,
    :roa    =>  6.5 ,
    :roc    =>  6.5 ,
    :gmar   =>  4.0 ,
    :omar   =>  4.0 ,
    :nmar   =>  4.0 ,
    :grwth  =>  3.9 ,
    :epscon =>  1.8 ,
    :de     => 4.54 ,
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
