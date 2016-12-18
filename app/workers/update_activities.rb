class UpdateActivities
  include Sidekiq::Worker
  
  def perform(activity)    
    activity = activity.split(',')
    activity_classname = activity[0] 
    activity_id = activity[1] 
    activity_date = activity[2] 
    updated_by = activity[3] 
    
    if activity_classname == "Task"
      record = Task.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = updated_by
        activity_desc = record.get_title
        activity_status = record.is_completed == true ? "Complete" : "Update"
        puts "------------------------- updating task -----------------------"
        p activity_status
        
        
        record_status = (!record.taskable.nil? || !record.taskable.blank?) ?  (!record.taskable.is_public.nil? ? record.taskable.is_public : false) : false
        source_id = record.taskable.id
        source = record.taskable
      end
       
    elsif activity_classname == "Deal"
      record = Deal.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = updated_by
        activity_desc = record.title
        puts "-----------------------------------deals worker"
        p record.is_active
        activity_status = record.is_active == true ? "Update" : "Archive"
        record_status = (record.is_public.nil? ||  record.is_public.blank?) ? false : record.is_public
        source_id = record.id
        source = record
      end
      
    elsif activity_classname == "CompanyContact"
      record = CompanyContact.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = updated_by
        activity_desc = record.full_name
        activity_status = record.is_active == true ? "Update" : "Archive"
        record_status = (record.is_public.nil? ||  record.is_public.blank?) ? false : record.is_public
        source_id = nil
      end
      
    elsif activity_classname == "IndividualContact"
      record = IndividualContact.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = updated_by
        activity_desc = record.full_name
        activity_status = record.is_active == true ? "Update" : "Archive"
        record_status = (record.is_public.nil? ||  record.is_public.blank?) ? false : record.is_public
        source_id = nil
       end
       
     end
     
     if record.present?
           a1 = Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => activity_date, :is_public => record_status, :source_id => source_id)
           InsertContactActivities.perform_async("#{a1.id}")    if a1.id.present?
           if source.present? && a1.id.present?
             if  source.class.name == "Deal"
              source.update_column :last_activity_date,  a1.activity_date       
             end
           end
           
     end
      
      
  end 
    
end
