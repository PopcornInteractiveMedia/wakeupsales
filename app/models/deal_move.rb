class DealMove < ActiveRecord::Base
  belongs_to :organization
  belongs_to :deal
  belongs_to :deal_status
  belongs_to :user
  has_one :attachment, :as=>:notable,:class_name=>"Note"
  attr_accessible :organization, :deal,:deal_status,:deal_status_id,:deal_id,:created_at,:user
  attr_accessor :note,:is_current
  
  scope :by_deal_id_and_status_won, lambda{|deal_id,status| where("deal_id  = ? and deal_status_id = ?", deal_id, status)} 
  
  after_create :insert_deal_move_activity
  
  def title
     #self.deal_status.name + " " + deal.title
     deal.title
  end
  
  def insert_deal_move_activity
     Activity.create(:organization_id => self.organization_id,  :activity_user_id => self.user.id,:activity_type=> "DealMove", :activity_id => self.id, :activity_status => "Move",:activity_desc=>self.deal.title,:activity_date => self.updated_at, :is_public => (self.deal.is_public.nil? ||  self.deal.is_public.blank?) ? false : self.deal.is_public, :source_id => self.deal.id)
  end  
  
end
