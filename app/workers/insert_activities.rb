class InsertActivities
  include Sidekiq::Worker
  
  def perform(activity)
    
    activity = activity.split(',')
    activity_classname = activity[0] 
    activity_id = activity[1] 
    activity_date = activity[2] 
    
    puts "--------------inside sidekiq worker"
    
    
    
    is_flag = false
    if activity_classname == "Task"
      record = Task.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = record.created_by
        activity_desc = record.get_title
        activity_status = "Create"
        is_flag = true
        public_status = (!record.taskable.nil? || !record.taskable.blank?) ?  (!record.taskable.is_public.nil? ? record.taskable.is_public : false) : false
        source_id = record.taskable.class.name == "Deal" ? record.taskable.id :  nil
        source = record.taskable.class.name == "Deal" ? record.taskable :  nil
      end
      
    elsif activity_classname == "Deal"
      record = Deal.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = record.initiated_by
        activity_desc = record.title
        activity_status = "Create"
        public_status = (record.is_public.nil? ||  record.is_public.blank?) ? false : record.is_public 
        is_flag = true
        source_id = record.id
        source = record
      end
      
    elsif activity_classname == "DealMove"
      record = DealMove.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = record.user.id
        activity_desc = record.deal.title if record.deal
        activity_status = "Move"
        public_status = (record.deal.nil? ||  record.deal.blank?) ? false : ( !record.deal.is_public.nil? ? record.deal.is_public : false)
        source_id = record.deal.id
        source = record.deal
        is_flag = false
      end
      
    elsif activity_classname == "Note"
      record = Note.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = record.created_by
        activity_desc = record.notes
        activity_status = "Create"
        unless record.notable_type == "DealMove"
          public_status = (record.notable.nil? ||  record.notable.blank?) ? false : (!record.notable.is_public.nil? ? record.notable.is_public : false)
          source_id = record.notable.id
          source = record.notable
        else
          public_status = (record.notable.deal.nil? ||  record.notable.deal.blank?) ? false :  (!record.notable.deal.is_public.nil? ? record.notable.deal.is_public : false)
          source_id = record.notable.deal.id
          source = record.notable.deal
        end
        is_flag = false
      end
      
    elsif activity_classname == "CompanyContact"
      record = CompanyContact.find activity_id.to_i
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = record.created_by
        activity_desc = record.full_name
        activity_status = "Create"
        public_status = (record.is_public.nil? ||  record.is_public.blank?) ? false : record.is_public   
        source_id = nil
        is_flag = false
      end
      
    elsif activity_classname == "IndividualContact"
      record = IndividualContact.find activity_id.to_i
      puts "&&&&&&&&&&&&&&&&********************* check contatc"
      p record
      if record.present?
        org_id = record.organization_id if record.organization_id
        activity_type = activity_classname
        activity_id =  record.id       
        activity_user_id = record.created_by
        activity_desc = record.full_name
        activity_status = "Create"
        public_status = (record.is_public.nil? ||  record.is_public.blank?) ? false : record.is_public   
        source_id = nil
        is_flag = false
      end
    end
   if record.present?
      if is_flag == true 
        
         txt = "#{activity_classname} is assigned"
         p txt
         p activity_classname
         a2 = Activity.create(:organization_id => org_id,	:activity_user_id => activity_classname == "Task" ? (record.user.present? ?
 record.user.id : "") : (record.assigned_user.present? ? record.assigned_user.id : ""), :activity_type=> activity_type, :activity_id => activity_id, :activity_status => "Assign",:activity_desc=>activity_desc,:activity_date => activity_date, :is_public => public_status, :source_id => source_id)
          InsertContactActivities.perform_async("#{a2.id}")    if a2.id.present?
         #if((activity_classname == "Deal") || (activity_classname == "DealMove") || (activity_classname == "CompanyContact") || (activity_classname == "IndividualContact"))
          a1 = Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => activity_date, :is_public => public_status, :source_id => source_id)
          InsertContactActivities.perform_async("#{a1.id}")    if a1.id.present?
        #end
          
          if source.present? &&  a2.id.present?
            if  source.class.name == "Deal"
              source.update_column :last_activity_date,  a2.activity_date          
            end
          end
      else
         puts "####################################################"
         puts "========================================= else insert "
         p source
         #a3 = Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => activity_date, :is_public => public_status, :source_id => source_id)
          #InsertContactActivities.perform_async("#{a3.id}")    if a3.id.present?
          # if source.present? && a3.id.present?
            # if  source.class.name == "Deal"
              # source.update_column :last_activity_date,  a3.activity_date          
            # end
          # end
      end 
    end
      
      
  end 
    
end
