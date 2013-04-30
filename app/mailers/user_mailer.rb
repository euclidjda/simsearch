class UserMailer < ActionMailer::Base
  default from: "Euclidean Fundamentals"

  def welcome_email(_user)
    @user = _user
    @url  = "http://www.euclidean.com/fundamentals"
    mail( :to => @user.email, 
          :subject => "Welcome to Euclidean Fundamentals")
  end

  def share_email(_user, _target, _message, _search_id)
    @user = _user
    @url = "http://www.euclidean.com/fundamentals?search=" + _search_id
    mail( :to => _target, 
          :subject => "Shared search results")

  end

end
