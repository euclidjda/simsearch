class FeedbackMailer < ActionMailer::Base
  default :from => 'web-mailer@euclidean.com'

  def feedback(feedback)
    @feedback = feedback
    mail(:to => 'info@euclidean.com', 
         :subject => '[Feedback for Euclidean Fundamentals] #{feedback.subject}')
  end
end
