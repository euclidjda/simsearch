Simsearch::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.logger = false
  config.assets.debug = false

  # The available log levels are: :debug, :info, :warn, :error, :fatal, and :unknown, 
  # corresponding to the log level numbers from 0 up to 5 respectively. 0/DEBUG is most verbose.

  # We create two different loggers, to be able to control ActiveRecord logging level 
  # and general logging level separately. They both write to STDOUT.

  theLogger = Logger.new(STDOUT)
  theLogger.level = Logger::INFO

  config.logger = theLogger
  config.log_level = Logger.const_get(
    ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'INFO'
  )

  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = Logger.const_get(
    ENV['DB_LOG_LEVEL'] ? ENV['DB_LOG_LEVEL'].upcase : 'INFO'
  )
  
end
