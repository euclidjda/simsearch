class FrontdoorController < ApplicationController
  protect_from_forgery

  helper_method :target_sec, :target_fields, :search_ids, :form_refresh?, :validation_error

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
        @target_fields = target.fields()

        @search_ids = Hash::new()

        FrontdoorHelper::epochs.each do |ep|
          
          fromdate = FrontdoorHelper::startDate(ep)
          thrudate = FrontdoorHelper::endDate(ep)
          
          search = Search::exec( :target      => target   ,
                                 :fromdate    => fromdate ,
                                 :thrudate    => thrudate ,
                                 :search_type => 'TypeA'  ,
                                 :limit       => 10       )
          
          @search_ids[ep] = search.id
          
        end
        
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
  # Method that returns a search result via a search id as a json
  #
  def get_search_results
    _search_id = params[:search_id]

    result = Array::new(0)

    if !_search_id.blank?

      search = nil
      
      block_until_searches_are_complete( _search_id )
      
      details = SearchDetail.where( :search_id => _search_id )

      details.each do |d|

        comp_record = Hash::new()
        
        comp_record[:distance] = d.dist
        comp_record[:stk_rtn]  = d.stk_rtn
        comp_record[:mrk_rtn]  = d.mrk_rtn
        
        snapshot = SecuritySnapshot::get_snapshot(d.cid,d.sid,d.pricedate)
        
        snapshot.fields.keys.each do |key|
          comp_record[key] = snapshot.fields[key]
        end
        
        snapshot.factor_keys.each do |key|
          comp_record[key] = snapshot.get_factor(key)
        end
        
        result.push(comp_record)
        
      end

    end

    if result.empty?

      result[0] = "No comaprables for this epoch"

    end

    render :json => result.to_json

  end

  def get_search_summary

    _search_id_list = params[:search_id_list]
    
    block_until_searches_are_complete( _search_id_list )

    # TODO: JDA: Validate search_id_list before SQL
    search_details = SearchDetail.where("search_id IN ("+_search_id_list+")")

    perfs = Array::new()
    weight_sum = 0
    values_sum = 0

    search_details.each do |detail|

      next unless detail.dist > 0

      weight = Math.exp( -detail.dist )

      values_sum += weight * (detail.stk_rtn-detail.mrk_rtn) 
      weight_sum += weight

    end

    result = Hash::new()

    result[:summary] = values_sum / weight_sum

    render :json => result.to_json

  end

  def block_until_searches_are_complete( _search_id_list )

    (0..40).each do |step| 

      count = 100

      Search.uncached do
        count = Search.where("id IN ("+_search_id_list+") AND completed = 0").count()
      end

      logger.debug "******* COUNT IS #{count}"
     
      break if count == 0
 
      sleep(2)

    end

  end

private

  def target_sec
    @target_sec
  end

  def target_fields
    @target_fields
  end

  def search_ids
    @search_ids
  end

  def median(arr)
    sorted = arr.sort
    len = sorted.length
    median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2
  end

  def form_refresh?
    @form_refresh
  end

  def validation_error
    @validation_error
  end
end

module QueryEM
  def self.start
    
    # faciliates debugging
    Thread.abort_on_exception = true
    # just spawn a thread and start it up
    Thread.new { 
      EM.run 
    }
  end
  
  def self.die_gracefully_on_signal
    Signal.trap("INT")  { EM.stop }
    Signal.trap("TERM") { EM.stop }
  end
end

QueryEM.start
