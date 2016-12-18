class InsertContactActivities
  include Sidekiq::Worker
  
  def perform(activity)
        activity = Activity.find activity.to_i
        puts "------------- InsertContactActivities   --------------- "
        p activity
        case activity.activity_type
          
          when "Note"
              record = Note.find activity.activity_id
              org_id = activity.organization_id
              if record.notable_type == "CompanyContact" || record.notable_type == "IndividualContact"
                contactable_id = record.notable.id
                contactable_type = record.notable_type
                ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
              end
              
           when "Task"
              record = Task.find activity.activity_id
              org_id = activity.organization_id
              if record.taskable.class.name == "CompanyContact" || record.taskable.class.name == "IndividualContact"
                contactable_id = record.taskable.id
                contactable_type = record.taskable.class.name
                ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
              end
            
            when "Deal"
              record = Deal.find activity.activity_id
              org_id = activity.organization_id
              record.deals_contacts.each do |c|
                contactable_id = c.contactable.id
                contactable_type = c.contactable.is_individual? ? "IndividualContact" : "CompanyContact"
                ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
              end
             
             when "CompanyContact"
                record = CompanyContact.find activity.activity_id
                org_id = activity.organization_id
                contactable_id = record.id
                contactable_type = activity.class.name
                ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
         
              when "IndividualContact"
                record = IndividualContact.find activity.activity_id
                org_id = activity.organization_id
                contactable_id = record.id
                contactable_type = activity.class.name
                ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
        end
      
      
  end 
    
end
