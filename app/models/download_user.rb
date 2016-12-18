class DownloadUser < ActiveRecord::Base
  attr_accessible :email, :ip_address, :name
end
