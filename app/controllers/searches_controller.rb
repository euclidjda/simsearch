class SearchesController < ApplicationController

  protect_from_forgery

  @searches_path = nil
  @search_action_list = nil

  def searches
    if current_user
      @searches_path = request.fullpath
      render :searches
    else
      render :text => "need to sign in. this is here to protect for random get calls."
    end
  end
  
end
