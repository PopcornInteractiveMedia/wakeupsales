class DealsContact < ActiveRecord::Base
   attr_accessible :organization_id, :deal_id, :contactable_type, :contactable_id, :created_at, :updated_at
   belongs_to :contactable , :polymorphic=> true
   belongs_to :deal
   
   after_create :insert_activty_for_deal
   
   
   
   
   
   
   def insert_activty_for_deal

   if self.deal.is_remote? 
	  curuser=User.where("organization_id=? and admin_type=1", ENV['andolaORG'].to_i).first
	 else
	  curuser= User.current
	 end
	 
     Activity.create(:organization_id => self.organization_id,	:activity_user_id =>curuser.id,:activity_type=> self.class.name, :activity_id => self.id, :activity_status => "Add",:activity_desc=>self.contactable.full_name,:activity_date => self.created_at, :is_public => true, :source_id => self.deal_id)
	 
   
   end
   
end
