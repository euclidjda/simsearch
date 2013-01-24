class UserMailer < ActionMailer::Base
  default from: "Welcome.Mailer@Netarota.com"

  def welcome_email(user)
    @user = user
    @url  = "http://Fundamentals.Euclidean.com"
    mail( :to => @user.email, 
          :from => "ferhane@gmail.com",
          :subject => "Welcome to Euclidean Fundamentals")
  end

end