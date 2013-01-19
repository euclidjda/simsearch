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
    _mail_id = params[:mail_address_entry];

    # find the user, if not create one.
    _user = User.create_with_email(_mail_id)

    if _user
      create_session(_user)
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

  def create_session(_user_arg)
      session[:user_id] = _user_arg.id
  end

  def search

    # Get the parameter from the parameter array, this is coming from the browser.
    _search_entry = params[:ticker]

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

  #
  # Method that returns, as a json, a list of tickers that are matching the term.
  #
  def autocomplete_security_ticker
    _term = params[:term]
    if _term && !_term.empty?

      if _term[0] == ':'
        term = term[1.._term.length]
        items = Filter.
          select("distinct id as cid, id as sid, name as shortname, description as longname").
          where("LOWER(CONCAT(name, description)) like ?", '%' + _term.downcase + '%').
          limit(10).order(:shortname)
      else
        items = Security.
          select("distinct cid, sid, ticker as shortname, name as longname").
          where("LOWER(CONCAT(ticker, name)) like ?", '%' + _term.downcase + '%').
          limit(10).order(:shortname)
      end

    else
      items = {}
    end

    render :json => json_for_autocomplete(items, :shortname, [:sid, :cid, :longname])
  end


private
  def target
    @target
  end

  def comparables
    @comparables
  end
end
