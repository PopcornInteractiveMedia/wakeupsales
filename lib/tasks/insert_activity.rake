namespace :wus do  
  
  #inserting past activity activitys
  task :insert_activity => :environment do
    puts "-------   inserting past activity activitys   -----------------------"
    Organization.find_each do |org|
       puts "--------   ===== Organization ======  --------    #{org.id}"
       activities = []
       org = Organization.find org.id
       activities << org.deals
       activities << org.deal_moves
       activities << org.contacts
       activities << org.tasks
       activities << org.attachments
       activities = activities.flatten.sort! { |x,y| y.created_at <=> x.created_at } 
       if activities.any?
          activities.each do |activity|
              is_flag = false
              if(activity.class.name == "Task")
                  org_id = activity.organization_id if activity.organization_id
                  activity_type = activity.class.name
                  activity_id =  activity.id       
                  activity_user_id = activity.created_by ? activity.created_by : ""
                  activity_desc = activity.get_title
                  activity_status = "Create"
                  activity_created = activity.created_at
                  public_status = (!activity.taskable.nil? || !activity.taskable.blank?) ?  (!activity.taskable.is_public.nil? ? activity.taskable.is_public : false) : false
                  is_flag = true
                  
              elsif activity.class.name == "Deal"
                org_id = activity.organization_id if activity.organization_id
                activity_type = activity.class.name
                activity_id =  activity.id       
                activity_user_id = activity.initiated_by ? activity.initiated_by : ""
                activity_desc = activity.title
                activity_status = "Create"
                #status = activity.is_public
                activity_created = activity.created_at
                public_status = (activity.is_public.nil? ||  activity.is_public.blank?) ? false : activity.is_public 
                is_flag = true
                
              elsif activity.class.name == "DealMove"
                org_id = activity.organization_id if activity.organization_id
                activity_type = activity.class.name
                activity_id =  activity.id       
                activity_user_id = activity.user ? activity.user.id : ""
                activity_desc = activity.deal.title if activity.deal
                activity_status = "Move"
                activity_created = activity.created_at
                public_status = (activity.deal.nil? ||  activity.deal.blank?) ? false : ( !activity.deal.is_public.nil? || !activity.deal.is_public.blank?  ? activity.deal.is_public : false)
                
              elsif activity.class.name == "Note"
                org_id = activity.organization_id if activity.organization_id
                activity_type = activity.class.name
                activity_id =  activity.id       
                activity_user_id = activity.created_by ? activity.created_by : ""
                activity_desc = activity.notes
                activity_status = "Create"
                activity_created = activity.created_at
                unless activity.notable_type == "DealMove"
                    public_status = (activity.notable.nil? ||  activity.notable.blank?) ? false :  (!activity.notable.is_public.nil? ? activity.notable.is_public : false)
                else
                    public_status = (activity.notable.deal.nil? ||  activity.notable.deal.blank?) ? false :  (!activity.notable.deal.is_public.nil? ? activity.notable.deal.is_public : false)
                end
                
              elsif activity.class.name == "CompanyContact"
                org_id = activity.organization_id if activity.organization_id
                activity_type = activity.class.name
                activity_id =  activity.id       
                activity_user_id = activity.created_by ? activity.created_by : ""
                activity_desc = activity.full_name
                activity_status = "Create"
                activity_created = activity.created_at
                public_status = (activity.is_public.nil? ||  activity.is_public.blank?) ? false : activity.is_public   
                
              elsif activity.class.name == "IndividualContact"
                org_id = activity.organization_id if activity.organization_id
                activity_type = activity.class.name
                activity_id =  activity.id       
                activity_user_id = activity.created_by ? activity.created_by : ""
                activity_desc = activity.full_name
                activity_status = "Create"
                activity_created = activity.created_at
                public_status = (activity.is_public.nil? ||  activity.is_public.blank?) ? false : activity.is_public   
              end
              
              unless org_id.nil? || org_id.blank?
                   if is_flag == true
                     Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => activity_created, :is_public => public_status)
                     
                     Activity.create(:organization_id => org_id,	:activity_user_id => activity.class.name == "Task" ? (activity.user.present? ? activity.user.id : "") : (activity.assigned_user.present? ? activity.assigned_user.id : ""),:activity_type=> activity_type, :activity_id => activity_id, :activity_status => "Assign",:activity_desc=>activity_desc,:activity_date => activity_created, :is_public => public_status)
                  else
                    Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => activity_created, :is_public => public_status)
                  end 
              end
              i = Activity.count
              puts "----------------- #{i}"
             
              
          end
       end
    
    end
  end
  
  
  
end
  
  
  
  
