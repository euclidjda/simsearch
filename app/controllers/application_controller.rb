class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :the_search_type
  helper_method :current_user_display_name
  # Uncomment next line to lockdown entire site
  before_filter :site_lockdown_authenticator

protected
  def site_lockdown_authenticator
    authenticate_or_request_with_http_basic do |username, password|
      case username
      when "admin"
        password == "fifthavenue"
      when "capiq"
        password == "compustat"
      else
        false
      end
    end
  end

private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_user_display_name
    @current_user.username
  end

  def the_search_type
    nil
  end

end
