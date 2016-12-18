class DealSource < ActiveRecord::Base
  belongs_to :organization
  belongs_to :deal
  belongs_to :source
   attr_accessible :organization,:deal,:source,:source_id,:deal_id
end
