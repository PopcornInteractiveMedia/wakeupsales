# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SalesCafe::Application.initialize!

#ENV['cloudfront'] = "http://d11oxq348wyj4g.cloudfront.net"
ENV['cloudfront'] = ""
ENV['andolaORG'] = "1"
ENV['mode'] = Rails.env
if Rails.env.development?
    ENV['url'] = "http://staging.wakeupsales.com/"
elsif Rails.env.production?
   ENV['url'] = "https://www.wakeupsales.com/" 
end
@@category = ["Skype", "GTalk", "Yahoo", "AOL", "Windows Live", "Digsby","Aim","MSN"]
