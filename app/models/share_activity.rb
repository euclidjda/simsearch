class ShareActivity < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :user_id, :search_id, :share_email, :share_message

  def self.share_history(_user_id, _search_id)
    obj_array = Array.new

    obj_array = ShareActivity.find(:all, 
      :conditions => {:user_id => _user_id, :search_id => _search_id})

    obj_array.to_json

  end

end
