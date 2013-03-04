class FrontdoorController < ApplicationController
  protect_from_forgery

  helper_method :target_sec, :target_fields, :form_refresh?, :validation_error, :epochs, :the_search

  @target_sec = nil
  @target_fields = nil
  @search_ids = nil
  @validation_error = nil

  def root
    # always redirect to home, redundant actually since routes.rb also does this.
    redirect_to :action => :home
  end

  def register
    _email = params[:register_email_entry]
    _username = params[:register_username_entry]
    _password = params[:register_password_entry]

    if !_email.blank? && !_username.blank? && !_password.blank?

      # create the user
      user = User.create_with_form_data(
          :email => _email,
          :username => _username,
          :password => _password
          )

      if user.errors.size > 0
        @form_refresh = :register
        @validation_error = user.errors.full_messages[0]
        render :action => :home, :notice => "Register failed."
      else
        create_session(user)
        UserMailer.welcome_email(user).deliver
        redirect_to root_path, :notice => "Register succeeded. Signed in."
      end

    end
  end

  def login
    _email = params[:login_email_entry];
    _password = params[:login_password_entry]

    # find the user, if not create one.
    user = User.find_by_email(_email)

    if user
      create_session(user)
    else
      render root_path, :notice => "User not found"
    end

    redirect_to root_path, :notice => "Signed in"
  end

  def home
    @form_refresh = nil;

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
    @target_sec = nil
    @target_fields = nil

    if !_search_entry.blank?
      # We currently on support one ticker and no filters.
      ticker_value = _search_entry.split(" ").first

      # The ticker can only match one result and that will be the first.
      @target_sec = ExSecurity::find_by_ticker(ticker_value)

      if !@target_sec.nil?

        target = SecuritySnapshot::get_target(@target_sec.cid,@target_sec.sid)

        # Get the target's factor fields
        @target_fields = target.to_hash()

        # TODO: JDA: Right now the epochs are static but they should be custom
        # in future iteration

        @epochs = [ Epoch.new( Date.parse('2000-01-01') ,Date.parse('2011-12-31') ),
                    Epoch.new( Date.parse('1990-01-01') ,Date.parse('1999-12-31') ),
                    Epoch.new( Date.parse('1980-01-01') ,Date.parse('1989-12-31') ),
                    Epoch.new( Date.parse('1970-01-01') ,Date.parse('1979-12-31') ) ]

        @the_search = Search::exec( :target      => target    ,
                                    :epochs      => @epochs   ,
                                    :search_type => 'foo'     ,
                                    :limit       => 10        )

      end

    end

    render :action => :home
    # streaming ...
    # render :action => :home, :stream => true

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
          where("LOWER(CONCAT(name, description)) like ?", '%' +
                _term.downcase + '%').
          limit(10).order(:shortname)
      else
        items = ExSecurity.
          select("distinct cid, sid, ticker as shortname, name as longname").
          where("dldtei IS NULL AND LOWER(CONCAT(ticker, name)) like ?", '%' +
                _term.downcase + '%').
          limit(10).order(:shortname)
      end

    else
      items = {}
    end

    render :json => json_for_autocomplete(items, :shortname, [:sid, :cid, :longname])
  end

  #
  # API method that returns a search result via a search id as a json
  #
  def get_search_results
    _search_id = params[:search_id]
    _fromdate  = params[:fromdate]
    _thrudate  = params[:thrudate]

    result = Array::new(0)

    if !_search_id.blank?

      if are_searches_complete?( _search_id )

        details = SearchDetail
          .where( "search_id = #{_search_id} AND "+
                  "pricedate BETWEEN '#{_fromdate}' AND '#{_thrudate}'")

        details.each { |d|

          snapshot = SecuritySnapshot::get_snapshot(d.cid,d.sid,d.pricedate)

          comp_record = snapshot.to_hash()

          comp_record[:distance] = d.dist
          comp_record[:stk_rtn]  = d.stk_rtn
          comp_record[:mrk_rtn]  = d.mrk_rtn

          result.push(comp_record)

        }

      else

        result = nil

      end

    end

    if result.nil?
      render :json => nil.to_json
    else
      render :json => result.to_json
    end

  end

  #
  # API like method that returns a search result summary via a list of
  # search ids. The result is a json object
  #

  def get_search_summary

    result = Hash::new()

    _search_id_list = params[:search_id_list]

    if are_searches_complete?( _search_id_list )

      search_details = SearchDetail.where("search_id IN ("+_search_id_list+")")

      perfs = Array::new()
      weight_sum = 0
      values_sum = 0

      search_details.each { |detail|

        next unless detail.dist > 0

        weight = Math.exp( -detail.dist )

        values_sum += weight * ( detail.stk_rtn - detail.mrk_rtn )
        weight_sum += weight

      }

      result[:summary] = (weight_sum > 0) ? (values_sum / weight_sum) : nil

    else

      result = nil

    end

    render :json => result.to_json

  end

  def get_price_time_series

    _cid = params[:cid]
    _sid = params[:sid]
    _pricedate = params[:pricedate]

    if !_cid.blank? && !_sid.blank? && !_pricedate.blank?

      startdate = Date.parse(_pricedate) - 182
      enddate   = Date.parse(_pricedate) + 366

      prices = ExPrice::find_by_range(_cid,_sid,startdate,enddate)

      render :json => prices.to_json

    else

      render :text => 'failed'

    end

  end

  def get_growth_time_series

    _cid = params[:cid]
    _sid = params[:sid]
    _pricedate = params[:pricedate]

    if !_cid.blank? && !_sid.blank? && !_pricedate.blank?

      type = 'ANN'
      fields = ['datadate','sale','opi']
      limit  = 4
      fundamentals = ExFundmts::get_time_series(_cid,_sid,_pricedate,type,fields,
                                                limit)

      render :json => fundamentals.to_json

    else

      render :text => 'failed'

    end

  end

private

  def target_sec
    @target_sec
  end

  def target_fields
    @target_fields
  end

  def the_search
    @the_search
  end

  def epochs
    @epochs
  end


  def form_refresh?
    @form_refresh
  end

  def validation_error
    @validation_error
  end

  def are_searches_complete?( _search_id_list )

    count = 1

    Search.uncached {
      count = Search.where("id IN (" +
                           _search_id_list+") AND completed = 0").count()
    }

    (count == 0) ? true : false

  end

end

