class ActivitiesContact < ActiveRecord::Base
   attr_accessible :organization_id, :activity_id, :contactable, :contactable_type, :contactable_id
   
   belongs_to :contactable , :polymorphic=> true
    belongs_to :activity, :foreign_key=>"activity_id"
   
end
