class TempLead < ActiveRecord::Base
  strip_attributes #automatically strips all attributes of leading and trailing whitespace
  
        attr_accessible :assigned_to, :comments, :company_name, :company_size, :contact_name,
         :country, :created_dt, :description, :designation, :email, :industry, :location, 
         :mobile, :phone, :priority, :source, :task_type, :technology, :title, 
         :user_id, :website,:facebook_url, :linkedin_url, :twitter_url, :extension,:skype_id, :task_type

  scope :by_user,  lambda{|user_id| where("user_id   = ? ", user_id)}  
 
 
  before_create :remove_break_line
 
 def remove_break_line
     #self.designation = designation.gsub("\n",' ') if designation.present?
     #self.location = location.gsub("\n",' ') if location.present?
     self.designation = designation.squish if designation.present?
     self.location = location.squish if location.present?
     self.company_name = company_name.squish if company_name.present?
     self.contact_name = contact_name.squish if contact_name.present?
 end
 
 
 
end
