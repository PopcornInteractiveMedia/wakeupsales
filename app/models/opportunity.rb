class Opportunity < ActiveRecord::Base
  attr_accessible :organization_id, :quarter, :total_deals, :user_id, :win, :won_deals, :year
end
