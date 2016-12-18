#if Rails.env == "production"
#  $redis = Redis.new(:host => '10.154.206.83', :port => 6379)
#else
#  $redis = Redis.new(:host => '192.168.2.110', :port => 6379)
#end
#$redis.client.reconnect