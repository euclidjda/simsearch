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
    _user = User.create_with_email(mail_id)

    if _user
      create_session _user
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

  def create_session(user_arg)
      session[:user_id] = user_arg.id
  end

  def search_for_ticker
    # Get the parameter from the parameter array, this is coming from the browser.
    _search_entry = params[:search_entry]

    # Default to nil, which pushes the "invalid query" response.
    @ticker_results = nil

    if !_search_entry.blank?
      # We currently on support one ticker and no filters.
      _ticker_value = _search_entry.split(" ").first

      # The ticker can only match one result and that will be the first.
      _sec = Security::find_by_ticker(_ticker_value)

      # Set the epoch start and end dates

      _start_date = '1900-12-31'
      _end_date   = '9999-12-31'
      _limit      = 10

      if !_sec.nil?
        #@ticker_results = "cid-sid for #{ticker_value} is #{sec.cid}-#{sec.sid}"

        @ticker_results = _sec.get_comparables(:start_date => _start_date ,
                                               :end_date   => _end_date   ,
                                               :limit      => _limit      )
      end
    end

    render :action => :home

    # Comment the above line and uncomment the line below to see JSON output 
    # with no rendering. Helps with debugging.
    # render :json => @ticker_results
    
  end

private 
  def result_set
    @ticker_results
  end

end
