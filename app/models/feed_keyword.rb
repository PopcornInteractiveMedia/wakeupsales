class FeedKeyword < ActiveRecord::Base

  attr_accessible :feed_tags, :organization
  scope :by_organization_id, lambda{|org_id| where("organization_id = ? ",org_id).select("feed_tags")}

  belongs_to :organization


  def self.get_feed_keywords org
    self.find_by_organization_id org
  end





end
