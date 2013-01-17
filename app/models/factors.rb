class Factors < Tableless

  attr_reader :cid, :sid, :datadate, :fields, :factors

  def initialize( _fields )

    # TODO: JDA: we want to assert this structure it args
    # cid, sid, datadate cannot be blank?
    @fields   = _fields
    @cid      = get_field('cid')
    @sid      = get_field('sid')
    @datadate = get_field('datadate')
    @factors  = Hash::new()

  end

  def self.get( _cid, _sid )

    obj = nil

    if !_cid.blank? && !_sid.blank?

      sqlstr = Factors::get_target_sql(_cid,_sid)
      
      result = ActiveRecord::Base.connection.select_one(sqlstr) 

      obj = new( result ) if !result.nil?
    
    end

    return obj

  end

  def get_field( _name )

    @fields[_name]

  end

  def each_match( _start_date, _end_date )

    if !_start_date.blank? && !_end_date.blank?

      # TODO: all of the following needs validation
      target_ind = get_field('idxind')
      target_div = get_field('idxdiv')
      target_new = get_field('idxnew')

      price = Float(get_field('price'))
      csho  = Float(get_field('csho'))
      eps   = Float(get_field('epspxq_ttm'))

      target_cap = csho * price if (price && price > 0 && csho && csho > 0)
      target_val = price / eps  if (price && price > 0 && eps )

      # puts "***** target_cap = #{target_cap} , target_val = #{target_val}"

      sqlstr = Factors::get_match_sql(@cid,
                                      target_ind,target_div,target_new,
                                      target_cap,target_val,
                                      _start_date,_end_date)
      
      results = ActiveRecord::Base.connection.select_all(sqlstr) 

      results.each { |record|

        yield Factors::new( record )

      }
    
    end

  end

  def distance(obj) 

    factor_keys = [:ey,:roc]
    # factor_keys = [:ey,:roc,:grwth,:epscon,:ae,:momentum]
    
    dist = 0.0

    factor_keys.each { |key|

      f1 = get_factor(key)
      f2 = obj.get_factor(key)
      
      next if f1.nil?

      if !f2.nil?
        dist += ( f1 - f2 ) * ( f1 - f2 )
      else
        dist = -1
        break
      end
        
    }

    dist

  end

  def to_s
    "cid => #{@cid} sid => #{@sid} datadate => #{@datadate}"
  end


  def get_factor(factor_key)

    return @factors[factor_key] if (@factors.has_key?(factor_key))

    factor_value = nil

    case factor_key

      when :ey # Earnings Yield

        oiadp  = get_field('oiadpq_ttm')
        mrkcap = get_field('price')*get_field('csho')
        debt   = get_field('dlttq_mrq').to_f + get_field('dlcq_mrq').to_f
        cash   = get_field('cheq_mrq').to_f
        pstk   = get_field('pstkq_mrq').to_f
        mii    = get_field('midnq_mrq').to_f + get_field('mibq_mrq').to_f

        denom  = mrkcap+debt+cash+pstk+mii

        factor_value = oiadp/denom if (!oiadp.nil? && denom != 0)

      when :roc # Return On Capital

        oiadp   = get_field('oiadpq_ttm')
        capital = get_field('seqq_mrq').to_f + get_field('dlttq_mrq').to_f

        factor_value = oiadp / capital if (!oiadp.nil? && capital != 0)

      when :grwth # Revenue Growth

        factor_value = get_field('saleq_4yISgx')

      when :epscon # Consistency of EPS growth

        factor_value = get_field('epspiq_10yISr')

      when :ae # Assets to Equity (Leverage)

        assets = get_field('atq_mrq').to_f
        equity = get_field('seqq_mrq')

        factor_value = assets / equity if (!equity.nil? && equity != 0)

      when :momentum # Momentum

        factor_value = get_field('pch6m')

        else
        
        puts "Error: unknown factor #{factor_key}!"

    end

  end
  
  def self.get_target_sql(cid,sid)
<<GET_TARGET_SQL
  SELECT A.datadate pricedate, B.datadate fpedate, A.*, B.*, C.* 
  FROM ex_prices A, ex_factdata B, securities C 
  WHERE A.cid = '#{cid}' AND A.sid = '#{sid}' 
  AND B.cid = '#{cid}' AND B.sid = '#{sid}' 
  AND C.cid = '#{cid}' AND C.sid = '#{sid}' 
  AND A.datadate BETWEEN B.fromdate AND B.thrudate 
  ORDER BY A.datadate DESC LIMIT 1
GET_TARGET_SQL
  end

  def self.get_match_sql(cid,target_ind,target_div,
                         target_new,target_cap,target_val, 
                         begin_date,end_date)

    target_clause_sql = 
      target_val.nil? ? "" : " AND #{target_val} BETWEEN idxvall AND idxvalh "

<<GET_TARGET_SQL
    SELECT A.datadate pricedate, B.datadate fpedate,A.*, B.*, C.* 
    FROM ex_prices A, 
    (SELECT * 
    FROM ex_factdata 
    WHERE idxind = '#{target_ind}'
    AND idxdiv   = #{target_div} 
    AND idxnew   = #{target_new} 
    AND idxcaph >= LEAST(0.5*#{target_cap},10000) 
    AND idxcapl <= 5.0*#{target_cap} 
    #{target_clause_sql} ) B, 
    securities C 
    WHERE A.cid = B.cid 
    AND A.sid = B.sid 
    AND A.cid = C.cid 
    AND A.sid = C.sid 
    AND A.price IS NOT NULL 
    AND A.csho IS NOT NULL 
    AND A.cid != '#{cid}' 
    AND A.datadate BETWEEN B.fromdate AND B.thrudate
    AND A.datadate BETWEEN '#{begin_date}' AND '#{end_date}'
GET_TARGET_SQL
  end
end
