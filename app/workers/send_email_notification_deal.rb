class SendEmailNotificationDeal
  include Sidekiq::Worker
  
  def perform(email,name,created_by,title,deal_id,reassign=false)
    if reassign == false
      Notification.send_deal_info(email,name,created_by,title,deal_id).deliver 
    #Notification.contact_us_mail(email,name,comment).deliver  
    else
      deals = Deal.where(:id => deal_id)
      Notification.bulk_lead_notification(email,name,deals,"reassign").deliver
    end
  end
    
end
