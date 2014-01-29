class UserMailer < ActionMailer::Base
  default from: "Euclidean Fundamentals"

  def welcome_email(_user)
    @user = _user
    @url  = "http://fundamentals.euclidean.com"
    mail( :to => @user.email, 
          :subject => "Welcome to Euclidean Fundamentals")
  end

  def share_email(_user, _target, _search_id, _company_name, _message, _overunder)
    @user = _user
    @url = "http://fundamentals.euclidean.com?search=" + _search_id
    @company_name = _company_name
    @message = _message
    @overunder = _overunder
    @search_id = _search_id
    mail( :to => _target, 
          :subject => "Shared search results")
  end

end
