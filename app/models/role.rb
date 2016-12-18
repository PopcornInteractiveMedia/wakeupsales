class Role < ActiveRecord::Base

  belongs_to :organization
  attr_accessible :name,:organization,:organization_id
end
