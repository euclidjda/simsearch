class SecuritySnapshot < Tableless

  @@factor_weights = [ 31.0, 6.5, 3.9, 1.8, 4.54, 5.26]

  attr_reader :cid, :sid, :pricedate, :fields, :factor_keys

  def initialize( _fields )

    @factor_keys    = [:ey,:roc,:grwth,:epscon,:ae,:mom]

    # TODO: JDA: we want to assert this structure it args
    # cid, sid, datadate cannot be blank?
    @fields    = _fields
    @cid       = get_field('cid')
    @sid       = get_field('sid')
    @pricedate = get_field('pricedate')

    csho   = @fields['csho']       ? Float(@fields['csho'])       : nil
    price  = @fields['price']      ? Float(@fields['price'])      : nil
    eps    = @fields['epspxq_ttm'] ? Float(@fields['epspxq_ttm']) : nil
    seqq   = @fields['seqq_mrq']   ? Float(@fields['seqq_mrq'])   : nil
    dvpsxm = @fields['dvpsxm_ttm'] ? Float(@fields['dvpsxm_ttm']) : nil

    if (price && csho)
      @fields['mrkcap'] = (csho * price) 
    else
      @fields['mrkcap'] = nil
    end

    if (price && price > 0 && eps)
      @fields['pe'] = (price / eps)
    else
      @fields['pe'] = nil
    end
    
    if (csho && price && seqq && seqq > 0)
      @fields['pb'] = ((csho * price) / seqq)
    else
      @fields['pb'] = nil
    end

    if (dvpsxm && price && price > 0)
      @fields['yield'] = (dvpsxm / price)
    else
      @fields['yield'] = 0
    end

  end

  def self.get_snapshot( _cid, _sid, _pricedate )

    obj = nil

    if !_cid.blank? && !_sid.blank?

      sqlstr = SecuritySnapshot::get_snapshot_sql(_cid,_sid,_pricedate)
      
      result = ActiveRecord::Base.connection.select_one(sqlstr) 

      obj = new( result ) if !result.nil?
    
    end

    return obj

  end

  def self.each_snapshots_on(_pricedate)

    sqlstr = SecuritySnapshot::get_snapshots_on_sql(_pricedate)

    result = ActiveRecord::Base.connection.select_all(sqlstr) 

    result.each { |record|

      yield SecuritySnapshot::new( record )

    }

  end

  def self.get_target( _cid, _sid )

    obj = nil

    if !_cid.blank? && !_sid.blank?

      sqlstr = SecuritySnapshot::get_target_sql(_cid,_sid)
      
      result = ActiveRecord::Base.connection.select_one(sqlstr) 

      obj = new( result ) if !result.nil?
    
    end

    return obj

  end

  def self.each

    dates = ActiveRecord::Base
      .connection
      .select_all("SELECT pricedate FROM ex_combined "+
                  "GROUP BY pricedate "+
                  "ORDER BY pricedate DESC;")

    dates.each { |daterec|

      pricedate = daterec['pricedate'].to_s

      result = ActiveRecord::Base
        .connection
        .select_all("SELECT * FROM ex_combined "+
                    "WHERE pricedate = '#{pricedate}';") 

      result.each { |record|

        yield SecuritySnapshot::new( record )

      }

    }

  end

  def self.distance(_obj0,_obj1)

    vec0 = (_obj0.class == SecuritySnapshot) ? _obj0.factor_array : _obj0
    vec1 = (_obj1.class == SecuritySnapshot) ? _obj1.factor_array : _obj1

    dist = 0
    dims = 0

    vec0.each_with_index do |val0,index|

      val1 = vec1[index]
      wght = @@factor_weights[index]

      next if val0.nil?

      if !val1.nil?
        dist += wght * ( val0 - val1 ) * ( val0 - val1 )
        dims += 1
      else
        dist = -1
        break
      end
        
    end

    return dims > 0 ? dist/dims : -1

  end
  
  def distance(_obj) 
    
    SecuritySnapshot::distance(self,_obj)
    
  end

  def self.nearest_neighbor( _obj )

    vec0 = _obj.class == SecuritySnapshot ? _obj.factor_array : _obj

    min_dist = nil
    nearest  = nil

    SecuritySnapshot.each do | factors |

      veci = factors.factor_array
      dist = SecuritySnapshot::distance(vec0,veci)
      
      if (nearest.nil? || (dist <= min_dist))
        min_dist = dist
        nearest  = factors
      end

    end

    return nearest

  end

  def nearest_neighbor
    SecuritySnapshot::nearest_neighbor(self)
  end

  def get_field( _name )
    @fields[_name]
  end

  def to_s

    "cid => #{cid} sid => #{sid} pricedate => #{pricedate}"

  end

  def to_hash

    result = Hash::new()

    @fields.keys.each do |key|
      result[key] = get_field(key)
    end
    
    @factor_keys.each do |key|
      result[key] = get_factor(key)
    end

    return result;

  end

  def factor_array

    @factor_keys.map { |key| get_factor(key) }

  end

  def get_factor(_factor_key)

    # return @factors[_factor_key] if (@factors.has_key?(_factor_key))

    factor_value = nil

    case _factor_key

    when :ey # Earnings Yield

      oiadp  = get_field('oiadpq_ttm')
      mrkcap = get_field('price').to_f * get_field('csho').to_f
      debt   = get_field('dlttq_mrq').to_f + get_field('dlcq_mrq').to_f
      cash   = get_field('cheq_mrq').to_f
      pstk   = get_field('pstkq_mrq').to_f
      mii    = get_field('midnq_mrq').to_f + get_field('mibq_mrq').to_f

      denom  = mrkcap+debt+cash+pstk+mii

      factor_value = oiadp/denom if (!oiadp.nil? && denom != 0)
      factor_value = 0.0 if (factor_value && factor_value < 0)

    when :roc # Return On Capital

      oiadp   = get_field('oiadpq_ttm')
      capital = get_field('seqq_mrq').to_f + get_field('dlttq_mrq').to_f

      factor_value = oiadp / capital if (!oiadp.nil? && capital != 0)
      factor_value = 0.0 if (factor_value && factor_value < 0)

    when :gmar # Gross Margin

      revenue = get_field('saleq_ttm').to_f
      cogs    = get_field('cogsq_ttm').to_f
      
      factor_value = (revenue - cogs)/revenue if (revenue > 0)
      factor_value = 0.0 if (factor_value && factor_value < 0)

    when :grwth # Revenue Growth

      factor_value = get_field('saleq_4yISgx')

    when :epscon # Consistency of EPS growth

      factor_value = get_field('epspiq_10yISr')

    when :ae # Assets to Equity (Leverage)

      assets = get_field('atq_mrq').to_f
      equity = get_field('seqq_mrq').to_f

      factor_value = equity / assets if (!equity.nil? && assets > 0)

    when :mom # Momentum

      factor_value = get_field('pch6m')

    else
      
      logger.debug "Error: unknown factor #{_factor_key}!"
      return nil

    end

    # if !factor_value.nil?
    #  factor_value = 1.0 if factor_value > 1.0
    #  factor_value = -1.0 if factor_value < -1.0
    # end

    # @factors[_factor_key] = factor_value

    return factor_value

  end

  def self.get_snapshot_sql(_cid,_sid,_pricedate)
<<GET_SNAPSHOT_SQL
  SELECT A.datadate pricedate, B.datadate fpedate, A.*, B.*, C.* 
  FROM ex_prices A, ex_factdata B, ex_securities C 
  WHERE A.cid = '#{_cid}' AND A.sid = '#{_sid}' 
  AND B.cid = '#{_cid}' AND B.sid = '#{_sid}' 
  AND C.cid = '#{_cid}' AND C.sid = '#{_sid}' 
  AND A.datadate = '#{_pricedate}'
  AND '#{_pricedate}' BETWEEN B.fromdate AND B.thrudate
GET_SNAPSHOT_SQL
  end

  def self.get_snapshots_on_sql(_pricedate)
<<GET_SNAPSHOTS_ON_SQL
  SELECT A.datadate pricedate, B.datadate fpedate, A.*, B.*, C.* 
  FROM ex_prices A, ex_factdata B, ex_securities C 
  WHERE A.cid = B.cid AND A.sid = B.sid 
  AND A.cid = C.cid AND A.sid = C.sid
  AND A.datadate = '#{_pricedate}'
  AND '#{_pricedate}' BETWEEN B.fromdate AND B.thrudate
GET_SNAPSHOTS_ON_SQL
  end
  
  def self.get_target_sql(_cid,_sid)
<<GET_TARGET_SQL
  SELECT A.datadate pricedate, B.datadate fpedate, A.*, B.*, C.* 
  FROM ex_prices A, ex_factdata B, ex_securities C 
  WHERE A.cid = '#{_cid}' AND A.sid = '#{_sid}' 
  AND B.cid = '#{_cid}' AND B.sid = '#{_sid}' 
  AND C.cid = '#{_cid}' AND C.sid = '#{_sid}' 
  AND A.datadate BETWEEN B.fromdate AND B.thrudate 
  ORDER BY A.datadate DESC LIMIT 1
GET_TARGET_SQL
  end

  def get_match_sql(_search_type,_fromdate,_thrudate)

    gics_level  = _search_type.gicslevel
    gics_idx    = "idx#{gics_level}"
    gics_code   = self.get_field(gics_idx)
    gics_clause = "A.#{gics_idx} = '#{gics_code}'"
    target_new  = self.get_field('idxnew')

    logger.debug "*********** gics_level=#{gics_level} gics_idx=#{gics_idx} gics_code=#{gics_code} gics_clause=#{gics_clause}"

    target_cap =
      self.get_field('mrkcap') ? Float(self.get_field('mrkcap')).round() : 0

    idxcaph_min = [10000,target_cap*0.5].min.round()
    idxcapl_max = (5.0*target_cap).round()

<<GET_MATCH_SQL
    SELECT A.*
    FROM ex_combined A
    WHERE #{gics_clause}
    AND A.idxnew = #{target_new}
    AND A.pricedate BETWEEN '#{_fromdate}' AND '#{_thrudate}'
    AND A.idxcapl <= #{idxcapl_max}
    AND A.idxcaph >= #{idxcaph_min}
    AND A.cid != '#{self.cid}' 
GET_MATCH_SQL
  end

  def self.get_match_sql_SLOWLY(_cid, _target_ind, _target_new, _target_cap,
                                _begin_date, _end_date)
    
    idxcaph_min = [10000,_target_cap*0.5].min.round()
    idxcapl_max = (5.0*_target_cap).round()

<<GET_MATCH_SQL
    SELECT A.datadate pricedate, B.datadate fpedate,A.*, B.*, C.* 
    FROM ex_prices A,  ex_factdata B,
    ex_securities C 
    WHERE A.cid = B.cid 
    AND A.sid = B.sid 
    AND A.cid = C.cid 
    AND A.sid = C.sid 
    AND A.price IS NOT NULL 
    AND A.csho IS NOT NULL 
    AND A.cid != '#{_cid}' 
    AND B.idxind = #{_target_ind}
    AND B.idxnew = #{_target_new} 
    AND B.idxcaph >= #{idxcaph_min}
    AND B.idxcapl <= #{idxcapl_max}
    AND A.datadate BETWEEN B.fromdate AND B.thrudate
    AND A.datadate BETWEEN '#{_begin_date}' AND '#{_end_date}'
GET_MATCH_SQL
  end
end
