class ExFundmts < ActiveRecord::Base

  def self.get_time_series(_cid, _sid, _effdate, _type, _fields, _limit)

    fields_str = _fields.join(',');

    # TODO: Make sure start and end are valid dates
    ExFundmts.all(:select     => fields_str,
                  :conditions => "cid='#{_cid}' AND sid='#{_sid}' 
                                  AND type ='#{_type}' 
                                  AND '#{_effdate}' BETWEEN fromdate AND thrudate
                                  AND datadate < '#{_effdate}'",
                  :order      => "datadate DESC",
                  :limit      => _limit
                  )
  end 

end # class ExFundmts
