class SearchDetail < ActiveRecord::Base
  attr_accessible :cid, :dist, :pricedate, :search_id, :sid, :stk_rtn, :mrk_rtn

  def sim_score
    return dist.nil? ? nil : 100 * ( 1 - dist )
  end

end
