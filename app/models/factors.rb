class Factors < Tableless

  attr_reader :cid, :sid, :datadate, :fields

  def initialize( args )

    # TODO: we want to assert this structure when it comes in
    @fields   = args[:fields]
    @cid      = @fields['cid']
    @sid      = @fields['sid']
    @datadate = @fields['datadate']

  end

  def self.get( args )

    cid = args[:cid]
    sid = args[:sid]
    datadate = args[:datadate]

    if !cid.blank? && !sid.blank? && !datadate.blank?

      # TODO: There must be a better way to do a multiline
      # quoted string an assign to sqlstr
      sqlstr = \
      "SELECT A.*,B.* "\
      "FROM ex_prices A, ex_factdata B, securities C "\
      "WHERE A.cid = '#{cid}' AND A.sid = '#{sid}' "\
      "AND B.cid = '#{cid}' AND B.sid = '#{sid}' "\
      "AND C.cid = '#{cid}' AND C.sid = '#{sid}' "\
      "AND A.datadate = '#{datadate}' "\
      "AND A.datadate BETWEEN B.fromdate AND B.thrudate; "

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
      #target_ind = @fields['idxind']
      #target_div = @fields['idxdiv']
      #target_new = @fields['idxnew']
      #target_cap = 1
      #target_val = 1

      sqlstr = "SELECT '21312' cid, '99' sid, 'blah' datadate"

      results = ActiveRecord::Base.connection.select_all(sqlstr) 

      results.each { |record|

        yield Factors::new( :fields => record )

      }
    
    end

  end

  def to_s
    "cid => #{@cid} sid => #{@sid} datadate => #{@datadate}"
  end

end
