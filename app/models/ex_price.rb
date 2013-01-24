class ExPrice < ActiveRecord::Base
  def to_s
    "cid:#{cid}, sid:#{sid}, datadate:#{datadate}, price:#{price}"
  end

  def self.find_by_range(_cid, _sid, _start_date, _end_date)

    mrkid = 'SP0500'

    # TODO: Make sure start and end are valid dates
    ExPrice.all(:select     => "ex_prices.*, p2.price AS mrk_price",
                :joins      => "LEFT OUTER JOIN ex_prices AS p2
                                ON p2.cid = '#{mrkid}' AND p2.sid = '01' 
                                AND p2.datadate = ex_prices.datadate",
                :conditions => "ex_prices.cid='#{_cid}' AND ex_prices.sid='#{_sid}' 
                                AND ex_prices.datadate BETWEEN '#{_start_date}' AND '#{_end_date}'"
                )
  end 

end # class ExPrice
