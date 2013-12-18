require 'uri'
require 'net/http'

class FrontdoorController < ApplicationController
  protect_from_forgery

  helper_method \
  :target_fields, 
  :comp_fields, 
  :the_search, 
  :the_search_detail,
  :the_search_type,
  :epochs, 
  :form_refresh?, 
  :validation_error

  @target_fields = nil
  @comp_fields = nil
  @the_search = nil
  @the_search_detail = nil
  @the_search_type = nil
  @validation_error = nil

  def root
    # always redirect to home, redundant actually since routes.rb also does this.
    redirect_to :action => :home
  end

  def home

    #reset state.
    @form_refresh = nil;
    session[:search_id] = nil
    session[:ticker] = nil

    if current_user
    else
      redirect_to "/register"
    end
  end

  def identity
    @identity_path = request.fullpath
    render :identity
  end

  def register
    _email = params[:register_email_entry]
    _username = params[:register_username_entry]
    _password = params[:register_password_entry]
    _captcha_challenge = params[:recaptcha_challenge_field]
    _captcha_response = params[:recaptcha_response_field]

    captcha_uri = URI.parse("https://www.google.com/recaptcha/api/verify")
    http = Net::HTTP.new(captcha_uri.host, captcha_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(captcha_uri.path)
    req.set_form_data(
      'privatekey' => '6LfZiucSAAAAALSKd3ZGzeUeQAoAo6nmXWVPFdRo',
      'remoteip' => request.remote_ip,
      'challenge' => _captcha_challenge,
      'response' => _captcha_response
      )

    res = http.request(req)

    if res.body.index("true").nil?
      @form_refresh = :register 
      @validation_error = "Wrong captcha value entered"
      @identity_path = "/register"
      render :identity, :notice => "Register failed. Wrong captcha"
    else

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
          @identity_path = "/register"
          render :identity, :notice => "Register failed."
        else
          create_session(user)
          UserMailer.welcome_email(user).deliver
          redirect_to root_path, :notice => "Register succeeded. Signed in."
        end
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

  def update_username 
    if current_user
      newusername = params[:profile_username_entry]

      if !newusername.blank?

        current_user.username = newusername
        current_user.save!

        render :profile

      else
        redirect_to profile_path
      end
    else
      render :text => "Method requires signing in."
    end
  end

  def update_password
    if current_user

      _current_password = params[:profile_password_current]
      _new_password1 = params[:profile_password_new1]
      _new_password2 = params[:profile_password_new2]

      if _current_password.blank? || _new_password1.blank? || _new_password2.blank? 

        @current_password_error = "Please enter current password" if _current_password.blank?
        @new_password_error = "Please enter new password twice" if _new_password1.blank? || _new_password2.blank?
 
      else 

        #get the current password and check against the saved
        if current_user.match_password(_current_password)
          
          @current_password_error = ""

          if _new_password1 == _new_password2
            @new_password_error = ""

            # Original password is a match and we have the new one entered properly.
            # Let's update the password.

            current_user.password = _new_password1
            current_user.save!

            # Show the success message.
            @password_change_success = "Password was changed successfully."

          else
            @new_password_error = "New passwords do not match."
          end

        else
          @current_password_error = "Current password invalid."
        end

      end

      render :profile

    else
      render :text => "Method requires signing in."
    end
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

  def get_security_snapshot

    # only work when user is registered, we don't call this anywhere but from search
    # results, which is a registered user experience.
    #
    if current_user
      _search_id = params[:search_id]

      search = Search::where( :id => _search_id ).first

      target_cid = search.cid()
      target_sid = search.sid()

      search.ticker = ExSecurity.find_by_cidsid(target_cid, target_sid).ticker

      search_type = SearchType.where( :id => search.type_id ).first

      target_fields = 
        SecuritySnapshot
        .get_target(target_cid,target_sid).to_hash( :factor_keys => 
                                                    search_type.factor_keys )
      render :json => target_fields.to_json
    end

  end

  def search

    # Get the parameter from the parameter array, this is coming from the browser.
    _search_id    = params[:search_id]
    _search_entry = params[:ticker]

    # Default to nil, which pushes the "invalid query" response.
    @th_search = nil
    @the_search_detail = nil
    @target_fields = nil
    @comp_fields = nil
    @factor_data = Hash::new()
    @epochs = Epoch::default_epochs_array()

    if !_search_id.blank?
      
      # load the search
      @the_search = Search::where( :id => _search_id ).first

      target_cid = @the_search.cid()
      target_sid = @the_search.sid()

      @the_search.ticker = ExSecurity.find_by_cidsid(target_cid, target_sid).ticker

      @the_search_type = SearchType.where( :id => @the_search.type_id ).first

      @target_fields = 
        SecuritySnapshot
        .get_target(target_cid,target_sid).to_hash( :factor_keys => 
                                                    @the_search_type.factor_keys )

    elsif !_search_entry.blank?
      # We currently on support one ticker and no filters.
      ticker_value = _search_entry.split(" ").first

      # The ticker can only match one result and that will be the first.
      target_sec = ExSecurity::find_by_ticker(ticker_value)

      if !target_sec.nil?

        target = SecuritySnapshot::get_target(target_sec.cid,target_sec.sid)

        # This crazy method returns four values!
        factors, weights, gicslevel, newflag = process_search_form_params()

        # Get the target's factor fields
        @target_fields = target.to_hash( :factor_keys => factors )

        @the_search_type =
          SearchType::find_or_create(:factors   => factors    ,
                                     :weights   => weights    ,
                                     :gicslevel => gicslevel  ,
                                     :newflag   => newflag    )

          @the_search = Search::exec( :target      => target           ,
                                      :epochs      => @epochs          ,
                                      :search_type => @the_search_type ,
                                      :limit       => 10               ,
                                      :async       => true             ,
                                      :current_user => current_user    )

          @the_search.ticker = ticker_value

      end
    end

    # Add the information to the session so we can share the last search
    # across get/post requests.
    if @the_search 
      session[:search_id] = @the_search.id
      session[:type_id]   = @the_search.type_id
      session[:ticker]    = @the_search.ticker
    end

    # streaming ...
    render :action => :home, :stream => true

    # Comment the above line and uncomment the line below to see JSON output
    # with no rendering. Helps with debugging.
    # render :json => @comparables.to_json()

  end

  def search_detail

    _search_detail_id = params[:search_detail_id]

    @the_search = nil
    @the_search_detail = nil
    @the_search_type = nil
    @target_fields = nil
    @comp_fields = nil

    if !_search_detail_id.blank?

      @the_search_detail = SearchDetail.where( :id => _search_detail_id ).first

      if !@the_search_detail.nil?

        # Get the search data itself
        search = Search.where( :id => @the_search_detail.search_id ).first
        @the_search_type = SearchType.where( :id => search.type_id ).first

        # Get the target

        target_snapshot = SecuritySnapshot::get_snapshot(search.cid,
                                                         search.sid,
                                                         search.pricedate)
        
        @target_fields = 
          target_snapshot.to_hash( :factor_keys => 
                                   @the_search_type.factor_keys )


        comp_snapshot = 
          SecuritySnapshot::get_snapshot(@the_search_detail.cid,
                                         @the_search_detail.sid,
                                         @the_search_detail.pricedate)

        @comp_fields = 
          comp_snapshot.to_hash( :factor_keys => 
                                 @the_search_type.factor_keys )
      
      end

    end

    render :action => :home, :stream => true    
    # render :json => @comp_fields.to_json

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
        items1 = ExSecurity.
          select("distinct cid, sid, ticker as shortname, name as longname").
          where("dldtei IS NULL AND LOWER(ticker) like '#{_term.downcase}%'" ).
          limit(3).order(:shortname)

        items2 = ExSecurity.
          select("distinct cid, sid, ticker as shortname, name as longname").
          where("dldtei IS NULL AND LOWER(name) like '%#{_term.downcase}%'" ).
          limit(7).order(:shortname)

        items = items1.concat(items2)

        items.uniq! { |z| z.cid.concat(z.sid) }

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
          
          comp_record[:sim_score] = d.sim_score
          comp_record[:distance]  = d.dist
          comp_record[:stk_rtn]   = d.stk_rtn
          comp_record[:mrk_rtn]   = d.mrk_rtn

          comp_record[:search_detail_id] = d.id

          result.push(comp_record)

        }

      elsif !status.nil?

        result = status
        status.comment += "."
        status.save

      elsif !search.nil?

        result = Hash::new()
        result[:comment] = "Starting deep historical search for similar companies.."

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

  # API method that gets all info about a search

  def get_search_info

    result = Hash::new()

    _search_id = params[:search_id]

    search = Search.where( :id => _search_id ).first()

    if !search.nil? 

      search_type = SearchType.where( :id => search.type_id ).first()
      security = ExSecurity.where( :cid => search.cid, :sid => search.sid ).first()

      # Set results for json
      result[:ticker] = security.ticker
      result[:conm] = security.name
      result[:factors] = search_type.factors
      result[:weights] = search_type.weights
      result[:type_id] = search_type.id

    else

      result[:message] = "Bad search id"

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

  def the_search
    @the_search
  end

  def the_search_detail
    @the_search_detail
  end

  def the_search_type
    @the_search_type
  end

  def target_fields
    @target_fields
  end

  def comp_fields
    @comp_fields
  end

  def factor_data
    @factor_data
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
                                  :complete  => true       ).count()
    }

    # TODO: THIS SHOULD NOT BE HARD CODED AS "4"
    # IT SHOULD BE THE NUMBER OF EPOCHS
    (count == 4) ? true : false

  end

  def process_search_form_params

    # we need to convert param strings to sym
    factor_strings = [params[:factor1],params[:factor2],params[:factor3],
                      params[:factor4],params[:factor5],params[:factor6]]
    
    factors = factor_strings.map { |f| f.blank? ? nil : f.to_sym }
    
    weights = [params[:weight1],params[:weight2],params[:weight3],
               params[:weight4],params[:weight5],params[:weight6]]

    # TODO: THESE WE SHOULD GET FROM A DEFAULTS HELPER METHOD
    default_factors = Defaults::factors
    default_weights = Defaults::weights

    # Replace nils with defaults
    factors.each_index { |i| factors[i] = default_factors[i] if factors[i].nil? } 
    weights.each_index { |i| weights[i] = default_weights[i] if weights[i].nil? }

    # factors with zero weights are considered not selected
    factors.each_index { |i| factors[i] = :none if weights[i].to_f == 0 }

    # get defaults
    gicslevel = params[:gicslevel] || Defaults::gicslevel
    newflag   = params[:newflag]   || Defaults::newflag

    return factors, weights, gicslevel, newflag

  end

end

def get_autocomplete_sql(_term)

<<GET_AUTOCOMPLETE_SQL
  SELECT distinct cid, sid, ticker as shortname, name as longname
  FROM ex_securities
  WHERE dldtei IS NULL AND LOWER(ticker) like '#{_term}%'
  ORDER BY shortname 
  LIMIT 3 
GET_AUTOCOMPLETE_SQL
end
