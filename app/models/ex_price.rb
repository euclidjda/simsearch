class ExPrice < ActiveRecord::Base
  def to_s
    "cid:#{cid}, sid:#{sid}, datadate:#{datadate}, price:#{price}"
  end

  def self.find_by_range(cid,sid,start_date,end_date)

    # TODO: Make sure start and end are valid dates

    ExPrice.where("cid='#{cid}' AND sid='#{sid}' AND datadate BETWEEN '#{start_date}' AND '#{end_date}'")
  end 

end # class ExPrice
