class AttentionDeal < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  attr_accessible :organization_id, :user_id, :deal_ids, :deal_count
  serialize :deal_ids
end
