# Roles to be used for authorization during various stages. 
module SearchActionTypes
  Create = 1
  Share = 2
  Favorite = 3
end

class SearchAction < ActiveRecord::Base
  # user, search and action are references.
  # If the same action is taken more than once, the timestamps contain
  # the last update time. (created_at, updated_at)

  # Action => SearchActionTypes::Create/Share/Favorite

  attr_accessible :user_id, :search_id, :action_id

  def self.find_or_create(attributes)
    SearchAction.where(attributes).first || SearchAction.create(attributes)
  end

end
