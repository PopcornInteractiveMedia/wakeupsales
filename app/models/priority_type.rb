class PriorityType < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :original_id, :organization_id
  
  #to get the priority name as per organization
  def self.get_priority_name prio_id, org
    self.find_by_original_id_and_organization_id prio_id, org
  end
  
  #to update the priority name as per organization
  def self.update_priority_name hot, warm, cold, org
   priority = {"1" => hot, "2" => warm, "3" => cold}   
   priority.each_pair do |key, value|    
     PriorityType.get_priority_name(key,org).update_attribute(:name,value)
   end 
  end
  
end
