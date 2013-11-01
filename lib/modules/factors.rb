class Factors

  @@FactorAttributes = {
    :ey     => { :order =>   1, :iw =>   31.0, :name => "Earnings Yield",    :fmt => "pct" },
    :pe     => { :order =>  10, :iw =>   0.01, :name => "Price to Earnings", :fmt => "%.2f" },
    :pb     => { :order =>  20, :iw =>   0.02, :name => "Price to Book",     :fmt => "%.2f" },
    :divy   => { :order =>  30, :iw =>   33.3, :name => "Dividend Yield"    },
    :roe    => { :order =>  40, :iw =>   0.42, :name => "Return on Equity"  },
    :roa    => { :order =>  50, :iw =>   10.5, :name => "Return on Assets"  },
    :roc    => { :order =>  60, :iw =>    6.5, :name => "Return on Capital" },
    :roic   => { :order =>  65, :iw =>   0.15, :name => "Return On Invested Capital" },
    :gmar   => { :order =>  70, :iw =>    4.3, :name => "Gross Margin"      },
    :omar   => { :order =>  80, :iw =>    6.8, :name => "Operating Margin"  },
    :nmar   => { :order =>  90, :iw =>    6.8, :name => "Net Margin"        },
    :grwth  => { :order => 100, :iw =>    3.9, :name => "Revenue Growth (yr)"},
    :epscon => { :order => 110, :iw =>    1.8, :name => "EPS Growth Consist. (10yr)", :fmt => "%.2f" },
    :de     => { :order => 120, :iw =>   0.06, :name => "Debt to Equity", :fmt => "%.2f" },
    :ae     => { :order => 130, :iw =>    4.5, :name => "Assets to Equity", :fmt => "%.2f" },
    :mom1   => { :order => 140, :iw =>   15.1, :name => "Price Momentum (1mo)"},
    :mom3   => { :order => 150, :iw =>    8.1, :name => "Price Momentum (3mo)"},
    :mom6   => { :order => 160, :iw =>    5.3, :name => "Price Momentum (6mo)"},
    :mom9   => { :order => 170, :iw =>    3.7, :name => "Price Momentum (9mo)"},
    :mom12  => { :order => 180, :iw =>    3.8, :name => "Price Momentum (12mo)"}
  }

  def self.all
    return @@FactorKeys
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

      factor_value = oiadp/denom if (oiadp > 0 && denom > 0)

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

      factor_value = dividend  / price if (dividend > 0 && price > 0)

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

      factor_value = oiadp / inv_cap if (oiadp > 0 && inv_cap > 0)

    when :roe # Return On Equity

      oiadp  = _snapshot.get_field('oiadpq_ttm').to_f
      equity = _snapshot.get_field('seqq_mrq').to_f

      factor_value = oiadp / equity if (oiadp > 0 && equity > 0)

    when :roa # Return On Assets

      oiadp  = _snapshot.get_field('oiadpq_ttm').to_f
      assets = _snapshot.get_field('atq_mrq').to_f

      factor_value = oiadp / assets if (oiadp > 0 && assets > 0)

    when :roc # Return On Capital

      oiadp   = _snapshot.get_field('oiadpq_ttm').to_f
      capital = _snapshot.get_field('seqq_mrq').to_f + _snapshot.get_field('dlttq_mrq').to_f

      factor_value = oiadp / capital if (oiadp > 0 && capital > 0)

    when :gmar # Gross Margin

      revenue = _snapshot.get_field('saleq_ttm').to_f
      cogs    = _snapshot.get_field('cogsq_ttm').to_f

      factor_value = (revenue - cogs)/revenue if (revenue > 0)

    when :omar # Op Margin

      revenue = _snapshot.get_field('saleq_ttm').to_f
      ebit    = _snapshot.get_field('oiadpq_ttm').to_f

      factor_value = ebit/revenue if (ebit > 0 && revenue > 0)

    when :nmar # Net Margin

      revenue = _snapshot.get_field('saleq_ttm').to_f
      net     = _snapshot.get_field('epspxq_ttm').to_f * _snapshot.get_field('csho')

      factor_value = net/revenue if (net > 0 && revenue > 0)

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
