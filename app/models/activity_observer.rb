class ActivityObserver < ActiveRecord::Observer
  observe :company_contact, :individual_contact, :deal_move

  def after_create(record)
   # InsertActivities.perform_async("#{record.class.name},#{record.id},#{Time.zone.now}")
    ##TODO commented for the timing..uncomment to make attention section work
    ##To remove the record from the attention deal table
#    UpdateAttentionDealWorker.perform_async("#{record.class.name},#{record.id}") if record.class.name == "Note" || record.class.name == "Task"
  end

  #def after_update(record)
    ##To remove the record from the attention deal table
  # if User.current.present?    
  #    UpdateActivities.perform_async("#{record.class.name},#{record.id},#{Time.zone.now},#{User.current.id}")    
  # end
    ## To update the attention deals information after update in "Deal" & "Task"
    ##TODO commented for the timing..uncomment to make attention section work
#    UpdateAttentionDealWorker.perform_async("#{record.class.name},#{record.id}") if record.class.name == "Deal" || record.class.name == "Task"

 # end
  
 def after_destroy(record)   
    if record.class.name == "Task"
        org_id = record.organization_id if record.organization_id
        activity_type = record.class.name
        activity_id =  record.id       
        activity_user_id = User.current.id
        activity_desc = record.get_title
        activity_status = "Archive"
        record_status = (!record.taskable.nil? || !record.taskable.blank?) ?  (!record.taskable.is_public.nil? ? record.taskable.is_public : false) : false
         Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => Time.zone.now, :is_public => record_status, :source_id => record.taskable.id)
    end
  end

end
