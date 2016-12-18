class SendEmailNotification
  include Sidekiq::Worker
  def perform(email,name,created_by,formated_due_date,title,url,type,type_id, is_event, event_start_date, event_end_date, deal_contact_id, deal_title, due_date)
    #Notification.send_task_info(user, initiator.full_name, self, self.taskable).deliver
    puts "=-=-=-=-++_=-=---------------------------------------------"
     #p is_event
     #p is_event && deal_contact_id.present?
     #if is_event && deal_contact_id.present?
     #  dc=DealsContact.find deal_contact_id
     #  contact=dc.contactable if dc
     #  con_email = contact.email
     #  con_name = contact.name
     #  #Notification.send_event_info(email,name,created_by,due_date,title,url,type,type_id, con_name, con_email).deliver
     #  Notification.send_event_info(email, event_start_date, event_end_date, title, deal_title, con_email).deliver
     #  Notification.send_event_info(con_email, event_start_date, event_end_date, title, deal_title, email).deliver
     #else
       Notification.send_task_info(email,name,created_by,formated_due_date, title,url,type,type_id).deliver
     #end
  end
end