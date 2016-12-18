class UserRole < ActiveRecord::Base
  belongs_to :organization
  belongs_to :role
  belongs_to :user
  attr_accessible :role_id, :organization_id
end
