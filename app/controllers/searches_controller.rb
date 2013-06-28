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
      # render UI that tells user that they need to sign in to share.
      render "askto_signin_modal"
    end
  end

  def share 
    # render :text => params[:hidden_search_id]

    if current_user
      search_action = SearchAction.find_or_create(:user_id => current_user.id,
                                                  :search_id => params[:hidden_search_id],
                                                  :action_id => SearchActionTypes::Share)
      search_action.touch()

      #Even if we found an existing share, to update the most recent share timestamp, do a save.
      search_action.save()

      UserMailer.share_email(current_user, 
        params[:share_email_entry], 
        params[:share_message_entry],
        params[:hidden_search_id]).deliver
    end

    render :text => "OK"
  end

  def addfavorite
    render :text => params

    search_action = SearchAction.find_or_create(:user_id => current_user.id,
                                                :search_id => params[:search_id],
                                                :action_id => SearchActionTypes::Favorite)

    search_action.touch()

    search_action.save()

  end
  
end
