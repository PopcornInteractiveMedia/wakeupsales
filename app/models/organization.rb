class Organization < ActiveRecord::Base
  attr_accessible  :beta_account_id, :deleted_at, :email, :is_active, :is_premium, :name, :size_id, :total_users, :website,:company_strength,:users,:description,:address_attributes,:phone_attributes,:time_zone
  
  has_many :priority_types, :dependent => :destroy
  has_many :deal_statuses, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :individual_contacts, :dependent => :destroy
  has_many :company_contacts, :dependent => :destroy
  has_many :sources, :dependent => :destroy
  has_many :deals, :dependent => :destroy
  has_many :task_types, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :industries, :dependent => :destroy
  has_many :deal_moves, :dependent => :destroy
  has_many :attachments, :class_name => "Note",:dependent => :destroy
  has_many :roles, :dependent => :destroy
  has_many :attention_deals, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  belongs_to :company_strength,:class_name=>"CompanyStrength",:foreign_key=>"size_id"

  has_many :task_priority_types , :dependent => :destroy
  has_one :address, :as => :addressable,:class_name=>"Address", :dependent => :destroy
  has_one :phone, :as => :phoneble,:class_name=>"Phone", :dependent => :destroy
  #callback to save some default data while creating organizations
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :phone

  #after_create :insert_default_data
  
  has_many :users,:foreign_key=>"organization_id", :dependent => :destroy
  
   attr_accessor :street, :state, :country, :city, :zip,:phone_no,:time_zone

  def insert_default_data
   ##1 - Hot, 2 - Warm, 3 - cold 
   priority = {"1" => "Hot", "2" => "Warm", "3" => "Cold"}   
   priority.each_pair do |key, value|    
     PriorityType.create :organization_id => self.id, :original_id => key, :name => value
   end  
   
   ##deafult task types for organization
   task_types = ["Appointment","Billing","Call","Documentation","Email","Follow-up","Meeting","None","Quote","Thank-you"]
   task_types.each do |task_name|
       TaskType.create :organization_id => self.id, :name => task_name
   end
   
   ##1 - New Deals, 2 - Qualified, 3 - Not Qualified, 4 - Won, 5 - Lost, 6 - Junk 
   #commented for new deal stages
   #priority = {"1" => "New Deals", "2" => "Qualified", "3" => "Not Qualified", "4" => "Won", "5" => "Lost", "6" => "Junk"}
   #priority.each_pair do |key, value|    
   #  DealStatus.create :organization_id => self.id, :original_id => key, :name => value
   #end
   deal_stages = DealStage.all
   deal_stages.each do |dealstage|
     DealStatus.create :organization_id => self.id, :original_id => dealstage.original_id, :name => dealstage.name
   end
	
   ##deafult roles for organization
   roles = ["Sales","Lead Generator"]
   roles.each do |role_name|
       Role.create :organization_id => self.id, :name => role_name
   end
   
  end  
  def hot_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",1])
  end
  def warm_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",2])
  end
  def cold_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",3])
  end
  def get_deal_status(original_id)
    dlstatus= self.deal_statuses.where("original_id = ?",original_id)
    return dlstatus
  end
  def incoming_deal_status
   return  self.deal_statuses.where("original_id = 1").first
  end
  def qualify_deal_status
   return  self.deal_statuses.where("original_id = 2").first
  end
  def not_qualify_deal_status
   return  self.deal_statuses.where("original_id = 3").first
  end
  def won_deal_status
   return  self.deal_statuses.where("original_id = 4").first
  end
  def lost_deal_status
   return  self.deal_statuses.where("original_id = 5").first
  end
  def junk_deal_status
   return  self.deal_statuses.where("original_id = 6").first
  end
  #Added new deal statuses
  def no_contact_deal_status
   return  self.deal_statuses.where("original_id = 7").first
  end
  def follow_up_required_deal_status
   return  self.deal_statuses.where("original_id = 8").first
  end
  def follow_up_deal_status
   return  self.deal_statuses.where("original_id = 9").first
  end
  def quoted_deal_status
   return  self.deal_statuses.where("original_id = 10").first
  end
  def meeting_scheduled_deal_status
   return  self.deal_statuses.where("original_id = 11").first
  end
  def forecasted_deal_status
   return  self.deal_statuses.where("original_id = 12").first
  end
  def waiting_for_project_requirement_deal_status
   return  self.deal_statuses.where("original_id = 13").first
  end
  def proposal_deal_status
   return  self.deal_statuses.where("original_id = 14").first
  end
  def estimate_deal_status
   return  self.deal_statuses.where("original_id = 15").first
  end 
  def get_deal_status(status_type)
    case status_type
      when 'new','incoming','lead'
        ds = self.deal_statuses.where("original_id = 1").first
      when 'pipeline','qualify'
        ds = self.deal_statuses.where("original_id = 2").first
      when 'won'
        ds = self.deal_statuses.where("original_id = 3").first
      when 'lost'
        ds = self.deal_statuses.where("original_id = 4").first
      when 'not_qualify'
        ds = self.deal_statuses.where("original_id = 5").first
      when 'junk','dead'
        ds = self.deal_statuses.where("original_id = 6").first
      when 'nocontact','no_contact'
        ds = self.deal_statuses.where("original_id = 7").first
      when 'follow_up_required'
        ds = self.deal_statuses.where("original_id = 8").first
      when 'follow_up'
        ds = self.deal_statuses.where("original_id = 9").first
      when 'quoted'
        ds = self.deal_statuses.where("original_id = 10").first
      when 'meeting_scheduled'
        ds = self.deal_statuses.where("original_id = 11").first
      when 'forecasted'
        ds = self.deal_statuses.where("original_id = 12").first
      when 'waiting_for_project_requirement'
        ds = self.deal_statuses.where("original_id = 13").first
      when 'proposal'
        ds = self.deal_statuses.where("original_id = 14").first
      when 'estimate'
        ds = self.deal_statuses.where("original_id = 15").first
    end
  end
end
