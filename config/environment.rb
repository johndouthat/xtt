# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'xtt'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/concerns )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_tt_session',
    :secret      => Xtt.config['secret']
  }

  config.gem 'tinder', :version => '1.2.0'
  config.gem 'fastercsv', :version => '1.2.3'
  config.gem 'googlecharts', :lib => "gchart", :version => '1.3.6'
  config.gem 'hpricot', :version => '>=0.6'
  config.gem 'net-toc', :lib => 'net/toc', :version => '0.2'
  config.active_support.use_standard_json_time_format = true
  config.active_record.include_root_in_json = true

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Activate observers that should always be running
  config.active_record.observers = [ :user_observer, :status_observer ]

  # Make Active Record use UTC-base instead of local time
  config.active_record.time_zone = "UTC"
  
  config.after_initialize do
    %w(ostruct md5).each { |lib| require lib }
    Bj.config["production.no_tickle"] = true if RAILS_ENV == 'production'
  end
end
