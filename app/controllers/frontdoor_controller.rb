class FrontdoorController < ApplicationController
  protect_from_forgery

  helper_method :target, :comparables

  @target = nil
  @comparables = nil

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
    # Home page rendering. There is not much as function here since most of the
    # activity is UI and that is handled in the view.

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
    @target = nil
    @comparables = nil

    if !_search_entry.blank?
      # We currently on support one ticker and no filters.
      _ticker_value = _search_entry.split(" ").first

      # The ticker can only match one result and that will be the first.
      _sec = Security::find_by_ticker(_ticker_value)

      if !_sec.nil?
        
        # Get the target's factor fields
        @target = Factors::get(_sec.cid,_sec.sid).fields()

        # Get a result set for each epoch
        @comparables = Hash::new()

        FrontdoorHelper.epochs.each { |_epoch|

          _start_date = FrontdoorHelper::startDate(_epoch)
          _end_date   = FrontdoorHelper::endDate(_epoch)

          @comparables[_epoch] = _sec.get_comparables(:start_date => _start_date ,
                                                      :end_date   => _end_date   ,
                                                      :limit      => 4           )
        }

      end

    end

    render :action => :home

    # Comment the above line and uncomment the line below to see JSON output 
    # with no rendering. Helps with debugging.
    # render :json => @comparables.to_json()
    
  end

private

  def target
    @target
  end

  def comparables
    @comparables
  end

end
