class SearchAction < ActiveRecord::Base
  # user, search and action are references.
  # If the same action is taken more than once, the timestamps contain
  # the last update time. (created_at, updated_at)
  attr_accessible :user_id, :search_id, :action_id

end
