class FrontdoorController < ApplicationController
  protect_from_forgery

  helper_method :target_fields, :form_refresh?, :validation_error, :epochs, :the_search

  @target_fields = nil
  @search_ids = nil
  @validation_error = nil

  def root
    # always redirect to home, redundant actually since routes.rb also does this.
    redirect_to :action => :home
  end

  def home

    @form_refresh = nil;

    if current_user
    end
  end

  def identity
    @identity_path = request.fullpath
    render :identity
    #render :text => request.fullpath
  end

  def register
    _email = params[:register_email_entry]
    _username = params[:register_username_entry]
    _password = params[:register_password_entry]

    if !_email.blank? && !_username.blank? && !_password.blank?

      logger.debug "****** we have all fields"

      # create the user
      user = User.create_with_form_data(
          :email => _email,
          :username => _username,
          :password => _password
          )

      if user.errors.size > 0

        @form_refresh = :register
        @validation_error = user.errors.full_messages[0]
        @identity_path = "/register"
        render :identity, :notice => "Register failed."
      else
        create_session(user)
        UserMailer.welcome_email(user).deliver
        redirect_to root_path, :notice => "Register succeeded. Signed in."
      end

    end
  end

  def signin
    _email = params[:signin_email_entry];
    _password = params[:signin_password_entry]

    # find the user, if not create one.
    user = User.find_by_email(_email)

    if user

      if user.match_password(_password)
        create_session(user)
        redirect_to root_path, :notice => "Signed in"
      else
        @form_refresh = "signin"
        @validation_error = "Invalid password"
        @identity_path = "/signin"
        render :identity, :notice => "Signin failded. Invalid passowrd."
      end

    else
      @form_refresh = "signin"
      @validation_error = "There is no user with this e-mail"
      @identity_path = "/signin"
      render :identity, :notice => "Signin failed. User not found."
    end
  end

  def destroy_session
    session[:user_id] = nil
    redirect_to root_path, :notice => 'Signed out'
  end

  def create_session(_user_arg)
      session[:user_id] = _user_arg.id
  end

  #redirect to search if we get a search with a ticker or search id on the 
  #address bar. This is to support sharing.
  def search_with_id

    _search_id    = params[:search_id]
    _search_entry = params[:ticker]

    if !_search_id.blank? || !_search_entry.blank?
      search
    else
      redirect_to root_path
    end
  end

  def search

    # Get the parameter from the parameter array, this is coming from the browser.
    _search_id    = params[:search_id]
    _search_entry = params[:ticker]

    # Default to nil, which pushes the "invalid query" response.
    @target_fields = nil

    if !_search_id.blank?
      
      # load the search
      @the_search = Search::where( :id => _search_id ).first

      target_cid = @the_search.cid()
      target_sid = @the_search.sid()

      search_type = SearchType.where( :id => @the_search.type_id ).first;

      @target_fields = 
        SecuritySnapshot
        .get_target(target_cid,target_sid).to_hash( :factor_keys => search_type.factor_keys )

      @epochs = Epoch::default_epochs_array()

    elsif !_search_entry.blank?
      # We currently on support one ticker and no filters.
      ticker_value = _search_entry.split(" ").first

      # The ticker can only match one result and that will be the first.
      target_sec = ExSecurity::find_by_ticker(ticker_value)

      if !target_sec.nil?

        target = SecuritySnapshot::get_target(target_sec.cid,target_sec.sid)

        factors = [params[:factor1],params[:factor2],params[:factor3],
                   params[:factor4],params[:factor5],params[:factor6]]

        weights = [params[:weight1],params[:weight2],params[:weight3],
                   params[:weight4],params[:weight5],params[:weight6]]

        factor_keys = factors.map { |f| f.to_sym }

        # Get the target's factor fields
        @target_fields = target.to_hash( :factor_keys => factor_keys )

        @epochs = Epoch::default_epochs_array()

        search_type =
          SearchType::find_or_create(:factors   => factor_keys        ,
                                     :weights   => weights            ,
                                     :gicslevel => params[:gicslevel] ,
                                     :newflag   => params[:newflag]   )

        @the_search = Search::exec( :target      => target      ,
                                    :epochs      => @epochs     ,
                                    :search_type => search_type ,
                                    :limit       => 10          ,
                                    :async       => true        )

      end

    end

    # streaming ...
    render :action => :home, :stream => true

    # Comment the above line and uncomment the line below to see JSON output
    # with no rendering. Helps with debugging.
    # render :json => @comparables.to_json()

  end

  #
  # Method that returns, as a json, a list of tickers that are matching the term.
  
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

    if !_search_id.blank? && !_fromdate.blank? && !_thrudate.blank?

      search = Search::where( :id => _search_id ).first

      status = SearchStatus::where( :search_id => _search_id ,
                                    :fromdate  => _fromdate  ,
                                    :thrudate  => _thrudate  ).first

      if !status.nil? && status.complete?

        search_type = SearchType.where( :id => search.type_id ).first;

        details = SearchDetail
          .where( "search_id = #{_search_id} AND "+
                  "pricedate BETWEEN '#{_fromdate}' AND '#{_thrudate}'")

        details.each { |d|

          snapshot = SecuritySnapshot::get_snapshot(d.cid,d.sid,d.pricedate)

          comp_record = snapshot.to_hash( :factor_keys => search_type.factor_keys )
          
          comp_record[:distance] = d.dist
          comp_record[:stk_rtn]  = d.stk_rtn
          comp_record[:mrk_rtn]  = d.mrk_rtn

          result.push(comp_record)

        }

      elsif !status.nil?

        result = status
        status.comment += "."
        status.save

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

    _search_id = params[:search_id]

    search = Search.where( :id => _search_id ).first()

    search.calculate_summary()

    # Set results for json

    result[:mean]  = search.mean
    result[:count] = search.count
    result[:wins]  = search.wins
    result[:min]   = search.min
    result[:max]   = search.max
    result[:complete] = are_searches_complete?(_search_id) ? 1 : 0

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

  def are_searches_complete?( _search_id )

    count = 1

    SearchStatus.uncached {
      count = SearchStatus.where( :search_id => _search_id ,
                                  :complete  => false      ).count()
    }

    (count == 0) ? true : false

  end

end

