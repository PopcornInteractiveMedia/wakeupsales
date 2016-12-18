class DealStatus < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :original_id, :organization_id
  
  #to get the priority name as per organization
  def self.get_deal_name deal_original_id, org
#    self.find_by_original_id_and_organization_id deal_original_id, org
    select("id, original_id, organization_id, name").where("original_id=? AND organization_id=?", deal_original_id, org).first
  end
  
  #to update the priority name as per organization
  def self.update_status deal, qualify, not_qualify, won, lost, junk, org
   priority = {"1" => deal, "2" => qualify, "3" => not_qualify, "4" => won, "5" => lost, "6" => junk}   
   priority.each_pair do |key, value|    
     self.get_deal_name(key,org).update_attribute(:name,value)
   end 
  end
  def is_incoming?
    return self.original_id == "1" ? true  : false
  end
  def is_qualified?
    return self.original_id == "2" ? true  : false
  end
  def is_not_qualified?
    return self.original_id == "3" ? true  : false
  end
  def is_won?
    return self.original_id == "4" ? true  : false
  end
  def is_lost?
    return self.original_id == "5" ? true  : false
  end
  def is_junk?
    return self.original_id == "6" ? true  : false
  end
end
