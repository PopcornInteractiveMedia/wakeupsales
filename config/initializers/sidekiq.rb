#require 'sidekiq'
#require 'sidekiq/web'

#Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
#  [user, password] == ["admin", "andolasidekiq"]
#end

#if Rails.env == "production"
#  Sidekiq.configure_server do |config|
#    config.redis = { :url => 'http://10.154.206.83:6379' }
#  end

#  Sidekiq.configure_client do |config|
#    config.redis = { :url => 'http://10.154.206.83:6379' }
#  end
#else
#  Sidekiq.configure_server do |config|
#    config.redis = { :url => 'http://192.168.2.110:6379' }
#  end

#  Sidekiq.configure_client do |config|
#    config.redis = { :url => 'http://192.168.2.110:6379' }
#  end
#end
