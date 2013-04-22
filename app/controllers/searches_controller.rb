class SearchesController < ApplicationController

  protect_from_forgery

  helper_method :the_search_type

  @searches_path = nil
  @search_action_list = nil

  @the_search_type = nil

  def the_search_type
    @the_search_type
  end

  def searches
    if current_user
      @searches_path = request.fullpath
      render :searches
    else
      render :text => "need to sign in. this is here to protect for random get calls."
    end
  end
  
end
