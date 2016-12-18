class SentEmailOpen < ActiveRecord::Base
  attr_accessible :email, :ip_address, :activity_id, :name, :opened
end
