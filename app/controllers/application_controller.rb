class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :current_user_display_name

  before_filter :site_lockdown_authenticator

protected
  def site_lockdown_authenticator
    authenticate_or_request_with_http_basic do |username, password|
      username == "admin" && password == "simsearch"
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
