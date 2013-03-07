class SearchStatus < ActiveRecord::Base
  attr_accessible :comment, :complete, :cur_step, :fromdate, :num_steps, :search_id, :thrudate

  # Return the first object which matches the attributes hash
  # - or -
  # Create new object with the given attributes
  #
  def self.find_or_create(attributes)
    SearchStatus.where(attributes).first || SearchStatus.create(attributes)
  end


end
