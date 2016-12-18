class UserPreference < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  attr_accessible :digest_mail_frequency, :weekly_digest, :organization_id, :user
end