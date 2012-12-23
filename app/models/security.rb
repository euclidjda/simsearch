class Security < ActiveRecord::Base
  attr_accessible :name, :ticker, :cid, :sid

  def to_s
    "cid:#{cid}, sid:#{sid}, ticker:#{ticker}, name:#{name}"
  end

  def self.find_by_ticker(ticker)
    Security.where(:ticker => ticker).first
  end 

  def get_comparables
    cid = params[:cid]
    sid = params[:sid]

    # TODO: JDA: support for querying on specific datadate instead of most recent
    # TODO: JDA: support for filters

    target    = nil
    distances = Array::new()
    result    = ""
  end
end
