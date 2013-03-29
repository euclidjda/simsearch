class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :current_user_display_name

  before_filter :site_lockdown_authenticator

protected
  def site_lockdown_authenticator
    authenticate_or_request_with_http_basic do |username, password|
      return true if (username == "admin" && password == "fifthavenue")
      return true if (username == "capiq" && password == "compustat")
      return false
    end
  end

private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_user_display_name
    @current_user.email
  end
end
