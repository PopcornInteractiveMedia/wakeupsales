class AddActivityByToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :activity_by, :integer
    
    Activity.where("activity_type =?","Deal").find_each do |ac|
   puts "started..........."
   p ac.id
   if ac.activity_status == 'Create' || ac.activity_status == 'Update'
     puts "create/update"
     ac_by = ac.activity_user_id.to_i
   else
    puts "assign/re-assign"
    dl = Deal.where("id =?",ac.activity_id).first
    if dl.present?
      ac_by = dl.initiated_by.to_i 
    end
   end
   puts "update"
   p ac_by
   ac.update_column(:activity_by, ac_by)
  end
  end
end
