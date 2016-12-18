# initializers/s3.rb
#if Rails.env == "production"
#  # set credentials from ENV hash
#  S3_CREDENTIALS = { :access_key_id => ENV['S3_KEY'], :secret_access_key => ENV['S3_SECRET'], :bucket => "ivplstaging"}
#else
  # get credentials from YML file
S3_CONFIG = YAML.load_file("#{::Rails.root}/config/s3.yml")
S3_CREDENTIALS = S3_CONFIG[::Rails.env]
#end