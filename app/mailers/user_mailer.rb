class UserMailer < ActionMailer::Base
  default from: "Euclidean Fundamentals"

  def welcome_email(_user)
    @user = _user
    @url  = "http://www.euclidean.com/fundamentals"
    mail( :to => @user.email, 
          :subject => "Welcome to Euclidean Fundamentals")
  end

  def share_email(_user, _target, _search_id, _message, _summary_text)
    @user = _user
    @url = "http://www.euclidean.com/fundamentals?search=" + _search_id
    @content = _summary_text
    mail( :to => _target, 
          :subject => "Shared search results")
  end

end
