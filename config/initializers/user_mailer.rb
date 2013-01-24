ActionMailer::Base.delivery_method = :smtp
 
ActionMailer::Base.smtp_settings = {
:enable_starttls_auto => true,
:address => 'smtp.gmail.com',
:port => 587,
:domain => "netarota.com",
:user_name => 'welcome.mailer@netarota.com',
:password => 'welcome!2013',
:authentication => 'plain'
}