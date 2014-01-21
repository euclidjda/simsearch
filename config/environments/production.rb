Simsearch::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Control fallback to assets pipeline if a precompiled asset is missed (true : compile, false : don't)
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  #########

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

  #########

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( jquery-ui-1.9.1.custom.min.css )
  # config.assets.precompile += %w( jquery-1.8.2.min.js )
  # config.assets.precompile += %w( jquery-ui-1.9.1.custom.min.js )
  # config.assets.precompile += %w( autocomplete-rails.js )
  # config.assets.precompile += %w( rails.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
