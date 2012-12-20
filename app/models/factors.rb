class Factors < Tableless

  attr_reader :cid, :sid, :datadate, :fields, :factors

  protected :factors

  def initialize( args )

    # TODO: we want to assert this structure when it comes in
    @fields   = args[:fields]
    @cid      = @fields['cid']
    @sid      = @fields['sid']
    @datadate = @fields['datadate']
    @factors  = Hash::new()

  end

  def self.get( args )

    cid = args[:cid]
    sid = args[:sid]

    if !cid.blank? && !sid.blank?

      # TODO: There must be a better way to do a multiline
      # quoted string an assign to sqlstr
      # TODO: THERE ARE MUTLIPLE DATADATE COLUMNS IN THIS QUERY
      sqlstr = \
      "SELECT * "\
      "FROM ex_prices A, ex_factdata B, securities C "\
      "WHERE A.cid = '#{cid}' AND A.sid = '#{sid}' "\
      "AND B.cid = '#{cid}' AND B.sid = '#{sid}' "\
      "AND C.cid = '#{cid}' AND C.sid = '#{sid}' "\
      "AND A.datadate BETWEEN B.fromdate AND B.thrudate "\
      "ORDER BY A.datadate DESC LIMIT 1"
      
      result = ActiveRecord::Base.connection.select_one(sqlstr) 

      obj = result ? new( :fields => result ) : nil
    
    end

    obj

  end

  def get_field( name )

    @fields[name]

  end

  def each_match( args )

    # self is target so you can extract to get cid,sid, etc
    if @cid && @sid

      # TODO: all of the following needs validation
      target_ind = @fields['idxind']
      target_div = @fields['idxdiv']
      target_new = @fields['idxnew']

      price = Float(@fields['price'])
      csho  = Float(@fields['csho'])
      eps   = Float(@fields['epspxq_ttm'])

      target_cap = csho * price if (price && price > 0 && csho && csho > 0)
      target_val = price / eps  if (price && price > 0 && eps && eps > 0)

      # puts "***** target_cap = #{target_cap} , target_val = #{target_val}"

      sqlstr = get_match_sql(target_ind,target_div,target_new,target_cap,target_val)
      
      results = ActiveRecord::Base.connection.select_all(sqlstr) 

      results.each { |record|

        yield Factors::new( :fields => record )

      }
    
    end

  end

  def distance(obj) 

    factor_keys = [:ey,:roc,:grwth,:epscon,:ae,:momentum]
    
    dist = 0.0

    factor_keys.each { |key|

      f1 = get_factor(key)
      f2 = obj.get_factor(key)
      
      next if f1 == nil

      if f2 != nil
        dist += ( f1 - f2 ) * ( f1 - f2 )
      else
        dist = -1
        last
      end
        
    }

    dist

  end

 def to_s
    "cid => #{@cid} sid => #{@sid} datadate => #{@datadate}"
  end

  def get_match_sql(target_ind,target_div,target_new,target_cap,target_val)
    "SELECT * "\
    "FROM ex_prices A, "\
    "(SELECT * "\
    "FROM ex_factdata "\
    "WHERE idxind = #{target_ind} "\
    "AND idxdiv   = #{target_div} "\
    "AND idxnew   = #{target_new} "\
    "AND idxcaph >= LEAST(0.5*#{target_cap},10000) "\
    "AND idxcapl <= 5.0*#{target_cap} "\
    "AND idxvall <= #{target_val} "\
    "AND idxvalh >= #{target_val}) B, "\
    "securities C "\
    "WHERE A.cid = B.cid "\
    "AND A.sid = B.sid "\
    "AND A.cid = C.cid "\
    "AND A.sid = C.sid "\
    "AND A.price IS NOT NULL "\
    "AND A.csho IS NOT NULL "\
    "AND A.cid != #{@cid} "\
    "AND A.datadate BETWEEN B.fromdate AND B.thrudate"
  end

  def get_factor(factor_key)

    return @factors[:factor_key] if (@factors[:factor_key] != nil)

    nil

  end

end
