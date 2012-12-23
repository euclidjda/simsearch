class FrontdoorController < ApplicationController
  protect_from_forgery

  helper_method :result_set

  def root
    # always redirect to home, redundant actually since routes.rb also does this.
    redirect_to :action => :home
  end

  def login
    mail_id = params[:mail_address_entry];

    # find the user, if not create one.
    user = User.create_with_email(mail_id)

    if user
      create_session user
    end

    redirect_to root_path, :notice => "Signed in"

  end

  def home
    # Home page rendering. There is not much as function here since most of the activity
    # is UI and that is handled in the view.

    if current_user
    end
  end

  def destroy_session
    session[:user_id] = nil
    redirect_to root_path, :notice => 'Signed out'
  end

  def create_session(user)
      session[:user_id] = user.id
  end

  def get_comparables 

    search_entry = params[:search_entry]

    # Default to nil, which pushes the "invalid query" response.
    @ticker_results = nil

    if !search_entry.blank?

      # We currently on support one ticker and no filters.
      ticker_value = search_entry.split(" ").first

      # The ticker can only match one result and that will be the first.
      sec = Security::find_by_ticker(ticker_value)

      if !sec.nil?
        #@ticker_results = "cid-sid for #{ticker_value} is #{sec.cid}-#{sec.sid}"

        @ticker_results = sec.get_comparables
      end
    end

    render :action => :home
  end

private 
  def result_set
    @ticker_results
  end

end
