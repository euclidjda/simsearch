ActionMailer::Base.delivery_method = :smtp
 
ActionMailer::Base.smtp_settings = {
:enable_starttls_auto => true,
:address => 'smtp.gmail.com',
:port => 587,
:domain => "euclidean.com",
:user_name => 'web-mailer@euclidean.com',
:password => 'welcome!2013',
:authentication => 'plain'
}
