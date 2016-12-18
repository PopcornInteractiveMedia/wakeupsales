SalesCafe::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true
  
 #Serving gzip assets from rails app 
  #config.middleware.insert_before ActionDispatch::Static, Rack::Deflater
  
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true


  # Disable Rails's static asset server (Apache or nginx will already do this)
  #config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true
  
	# Prefix all asset paths with asset_host
	#config.action_controller.asset_host = 'http://d11oxq348wyj4g.cloudfront.net'
	
	

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true
  config.assets.enabled = true
  #config.middleware.use ExceptionNotifier,
  #	 :email_prefix => "Exception occured in ",
  #	 :sender_address => %{"WakeUpSales Exception Notifier" <no-reply@wakeupsales.com>},
  #	 :exception_recipients => %w{deepak.dash@andolasoft.co.in, girijalaxmi.mishra@andolasoft.com}
	 
  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
   config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
   #config.assets.precompile += %w( home.css )
   #config.assets.precompile += %w( home.css jquery.stickysectionheaders.min.js jquery.stickysectionheaders.contact.min.js jquery.form.js jquery.edatagrid.js jquery.easyui.min.js  funnel.js contact_list_for_contact.js contact_list_all.js contact_list.js bootstrap-tagsinput.js bootstrap-editable.min.js bootstrap-better-typeahead.min.js autocomplete-rails.js dashboard.js other.js jsonly.js js_common.js js_datatable.js beoro.css bootstrap-better-typeahead.min.css bootstrap-formhelpers.less bootstrap-formhelpers-variables.less calendar.css default.css easyui.css fullcalendar.css home.css icon.css jquery.listnav-2.1.css wysiwyg-color.css profile.css bootstrap-glyphicons.css font-awesome.css other.css dashboard.css)
   #config.assets.precompile += %w( home.css icon.css contact.css contact_list_for_contact.js funnel.js jquery.easyui.min.js jquery.edatagrid.js jquery.min.map.js jquery.nicescroll.min.js jquery.powertip.min.js jquery.tagsinput.min.js )
   
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  #config.cache_store = :redis_store, 'http://10.154.206.83:6379/0/cache', { expires_in: 90.minutes }

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { :host => 'www.wakeupsales.com' }  
  
   
  # ActionMailer::Base.smtp_settings = {
  # :address              => "smtp.mandrillapp.com",
  # :enable_starttls_auto => true,
  # :port                 => 587 ,  #SSL is 465, and the port for TLS is 587
  # :domain               => "www.wakeupsales.com",
  # :user_name            => "test@test.com",
  # :password             => "hWAEsBR4JCcKoLzG-0RVug",
  # :authentication       => 'plain',
# }
end
