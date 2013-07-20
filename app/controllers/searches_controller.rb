class SearchesController < ApplicationController

  protect_from_forgery

  helper_method :the_search_type

  @search_action_list = nil

  @the_search_type = nil

  def the_search_type
    @the_search_type
  end

  def searches
    if current_user
      render :searches
    else
      # Our UI renders a dialog that tells users that they need to sign in to share.
      # In case someone is trying to get to this URL directly however, protect ourselves.
      redirect_to "/signin"
    end
  end

  def share 
    # render :text => params[:hidden_search_id]

    if current_user
      search_action = SearchAction.find_or_create(:user_id => current_user.id,
                                                  :search_id => params[:hidden_search_id],
                                                  :action_id => SearchActionTypes::Share)
      if search_action.action_count
        search_action.action_count += 1;
      else
        search_action.action_count = 1;
      end

      search_action.touch()

      #Even if we found an existing share, to update the most recent share timestamp, do a save.
      search_action.save()

      UserMailer.share_email(
        current_user, 
        params[:share_email_entry],
        params[:hidden_search_id], 
        params[:share_message_entry],
        params[:hidden_summary_text]).deliver
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
