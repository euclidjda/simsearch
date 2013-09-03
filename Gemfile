source 'https://rubygems.org'

gem 'rails', '3.2.8'

#using this gem gets us closer to rails 4.0 implementation of not putting logs
#into a file but to stdout, and it also removes Heroku deprecation warnings about
#deprecated plugins, which Heroku inserts if this is not there... not us.
gem 'rails_12factor', group: :production

#adding this to remove the rack warning for security. supposedly next rack update will fix it.
gem 'rack', '1.4.1'

gem "mysql2", "~> 0.3.11"
gem "eventmachine"

gem "unicorn", "4.5.0"

gem 'rails3-jquery-autocomplete'

gem 'delayed_job_active_record'

# won't be necessary once the data model settles in, keeping it here for now.
gem 'nifty-generators' 

gem 'bcrypt-ruby', :require => 'bcrypt'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'bootstrap-sass', '2.3.0'
  gem "font-awesome-rails"
  gem 'uglifier', '>= 1.0.3'
end