class UserMailer < ActionMailer::Base
  default from: "Euclidean Fundamentals"

  def welcome_email(user)
    @user = user
    @url  = "http://www.euclidean.com/fundamentals"
    mail( :to => @user.email, 
          :subject => "Welcome to Euclidean Fundamentals")
  end

end
