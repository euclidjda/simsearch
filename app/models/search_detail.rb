class SearchDetail < ActiveRecord::Base
  attr_accessible :cid, :dist, :pricedate, :search_id, :sid, :stk_rtn, :mrk_rtn

  def sim_score
    return (100 * (1-dist))
  end

end
