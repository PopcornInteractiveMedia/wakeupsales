class SalesCycle < ActiveRecord::Base
  attr_accessible :average, :longest, :organization_id, :quarter, :shortest, :user_id, :year
end
