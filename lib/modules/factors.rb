class Factors

  @@FactorAttributes = {
    :ey     => { :order =>   1, :mean => 0.0557, :stdev => 0.0214438782692542, :name => "Earnings Yield",    :fmt => "pct" },
    :pe     => { :order =>  10, :mean => 20.8045, :stdev => 13.975225597946,   :name => "Price to Earnings", :fmt => "%.2f" },
    :pb     => { :order =>  20, :mean => 2.8528, :stdev => 2.59227008614405,   :name => "Price to Book",     :fmt => "%.2f" },
    :divy   => { :order =>  30, :mean => 0.0188, :stdev => 0.0134990785161442, :name => "Dividend Yield"    },
    :roe    => { :order =>  40, :mean => 0.2233, :stdev => 0.147826546013839,  :name => "Return on Equity"  },
    :roa    => { :order =>  50, :mean => 0.0819, :stdev => 0.0557970254743573, :name => "Return on Assets"  },
    :roc    => { :order =>  60, :mean => 0.1379, :stdev => 0.0851770312397678, :name => "Return on Capital" },
    :roic   => { :order =>  65, :mean => 0.6739, :stdev => 1.69300251380807,   :name => "Return On Invested Capital" },
    :gmar   => { :order =>  70, :mean => 0.37905, :stdev => 0.495761842908608, :name => "Gross Margin"      },
    :omar   => { :order =>  80, :mean => 0.1599, :stdev => 0.103123661828404,  :name => "Operating Margin"  },
    :nmar   => { :order =>  90, :mean => 0.0946, :stdev => 0.0692244745886793, :name => "Net Margin"        },
    :grwth  => { :order => 100, :mean => 0.0694, :stdev => 0.0951013131859556, :name => "Revenue Growth (yr)"},
    :epscon => { :order => 110, :mean => 0.2317, :stdev => 0.523325667110766,  :name => "EPS Growth Consist. (10yr)", :fmt => "%.2f" },
    :de     => { :order => 120, :mean => 0.6259, :stdev => 0.792259593068915,  :name => "Debt to Equity", :fmt => "%.2f" },
    :ae     => { :order => 130, :mean => 0.3712, :stdev => 0.230472108707713,  :name => "Assets to Equity", :fmt => "%.2f" },
    :mom1   => { :order => 140, :mean => 0.03905, :stdev => 0.0505822909596408,:name => "Price Momentum (1mo)"},
    :mom3   => { :order => 150, :mean => 0.05485, :stdev => 0.0906983996154175,:name => "Price Momentum (3mo)"},
    :mom6   => { :order => 160, :mean => 0.12285, :stdev => 0.156255589961772, :name => "Price Momentum (6mo)"},
    :mom9   => { :order => 170, :mean => 0.18645, :stdev => 0.198813680649187, :name => "Price Momentum (9mo)"},
    :mom12  => { :order => 180, :mean => 0.30115, :stdev => 0.266923374490296, :name => "Price Momentum (12mo)"}
  }

      def self.keys
    return @@FactorAttributes.keys
  end

  def self.attributes(_factor_key)
    @@FactorAttributes[_factor_key]
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

  def self.format_factor(factor_key,factor_value)
    attr = @@FactorAttributes[factor_key]

    if factor_value.nil?
      return "N/A"
    elsif attr.nil? || attr[:fmt].nil? || attr[:fmt] == 'pct'
      return sprintf "%.2f%%",100*factor_value
    else
      return sprintf attr[:fmt],factor_value
    end

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

  def self.calc_factor(_snapshot,_factor_key)

    factor_value = nil

    case _factor_key

    when :ey # Earnings Yield

      oiadp  = _snapshot.get_field('oiadpq_ttm').to_f
      mrkcap = _snapshot.get_field('price').to_f * _snapshot.get_field('csho').to_f
      debt   = _snapshot.get_field('dlttq_mrq').to_f + _snapshot.get_field('dlcq_mrq').to_f
      cash   = _snapshot.get_field('cheq_mrq').to_f
      pstk   = _snapshot.get_field('pstkq_mrq').to_f
      mii    = _snapshot.get_field('midnq_mrq').to_f + _snapshot.get_field('mibq_mrq').to_f

      denom  = mrkcap+debt+cash+pstk+mii

      factor_value = oiadp/denom if (denom > 0)

    when :pe # Price to Earnings

      price    = _snapshot.get_field('price').to_f
      earnings = _snapshot.get_field('epspxq_ttm').to_f

      factor_value = price / earnings if (price > 0 && earnings > 0)

    when :pb # Price to Book

      price   = _snapshot.get_field('price').to_f * _snapshot.get_field('csho').to_f
      bookval = _snapshot.get_field('seqq_mrq').to_f

      factor_value = price / bookval if (price > 0 && bookval > 0)

    when :divy # Dividend Yield

      price    = _snapshot.get_field('price').to_f
      dividend = _snapshot.get_field('dvpsxm_ttm').to_f

      factor_value = dividend  / price if (price > 0)

    when :inv_cap # Invested Capital

      act    = _snapshot.get_field('actq_mrq').to_f
      lct    = _snapshot.get_field('lctq_mrq').to_f
      ppent  = _snapshot.get_field('ppent_mrq').to_f
      dlc    = _snapshot.get_field('dlcq_mrq').to_f

      factor_value = (act-lct) + ppent + dlc

    when :roic # Return on Invested capital

      oiadp  = _snapshot.get_field('oiadpq_ttm').to_f
      act    = _snapshot.get_field('actq_mrq').to_f
      lct    = _snapshot.get_field('lctq_mrq').to_f
      ppent  = _snapshot.get_field('ppent_mrq').to_f
      dlc    = _snapshot.get_field('dlcq_mrq').to_f

      inv_cap = (act-lct) + ppent + dlc

      factor_value = oiadp / inv_cap if (inv_cap > 0)

    when :roe # Return On Equity

      oiadp  = _snapshot.get_field('oiadpq_ttm').to_f
      equity = _snapshot.get_field('seqq_mrq').to_f

      factor_value = oiadp / equity if (equity > 0)

    when :roa # Return On Assets

      oiadp  = _snapshot.get_field('oiadpq_ttm').to_f
      assets = _snapshot.get_field('atq_mrq').to_f

      factor_value = oiadp / assets if (assets > 0)

    when :roc # Return On Capital

      oiadp   = _snapshot.get_field('oiadpq_ttm').to_f
      capital = _snapshot.get_field('seqq_mrq').to_f + _snapshot.get_field('dlttq_mrq').to_f

      factor_value = oiadp / capital if (capital > 0)

    when :gmar # Gross Margin

      revenue = _snapshot.get_field('saleq_ttm').to_f
      cogs    = _snapshot.get_field('cogsq_ttm').to_f

      factor_value = (revenue - cogs)/revenue if (revenue > 0)

    when :omar # Op Margin

      revenue = _snapshot.get_field('saleq_ttm').to_f
      ebit    = _snapshot.get_field('oiadpq_ttm').to_f

      factor_value = ebit/revenue if (revenue > 0)

    when :nmar # Net Margin

      revenue = _snapshot.get_field('saleq_ttm').to_f
      net     = _snapshot.get_field('epspxq_ttm').to_f * _snapshot.get_field('csho')

      factor_value = net/revenue if (revenue > 0)

    when :grwth # Revenue Growth

      factor_value = _snapshot.get_field('saleq_4yISgx')

    when :epscon # Consistency of EPS growth

      factor_value = _snapshot.get_field('epspiq_10yISr')

    when :de # Debt to Equity

      debt   = _snapshot.get_field('dlcq_mrq').to_f + _snapshot.get_field('dlttq_mrq').to_f
      equity = _snapshot.get_field('seqq_mrq').to_f

      factor_value = debt / equity if (!debt.nil? && equity > 0)

    when :ae # Assets to Equity (Leverage)

      assets = _snapshot.get_field('atq_mrq').to_f
      equity = _snapshot.get_field('seqq_mrq').to_f

      factor_value = equity / assets if (!equity.nil? && assets > 0)

    when :mom1 # Momentum

      factor_value = _snapshot.get_field('pch1m')

    when :mom3 # Momentum

      factor_value = _snapshot.get_field('pch3m')

    when :mom6 # Momentum

      factor_value = _snapshot.get_field('pch6m')

    when :mom9 # Momentum

      factor_value = _snapshot.get_field('pch9m')

    when :mom12 # Momentum

      factor_value = _snapshot.get_field('pch12m')

    when :none

      factor_value = nil

    else

      logger.debug "Error: unknown factor #{_factor_key}!"
      return nil

    end

    return factor_value

  end

end
