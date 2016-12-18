class DealIndustry < ActiveRecord::Base
  belongs_to :organization
  belongs_to :deal
  belongs_to :industry
  attr_accessible :organization,:deal,:industry,:industry_id,:deal_id
end
