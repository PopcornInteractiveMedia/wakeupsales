class LeadNotification
  include Sidekiq::Worker
  
  def perform()    
     dl = Deal.where(:is_csv => true).where(:is_mail_sent => false).group_by(&:assigned_to)
     #dl = Deal.where(:is_mail_sent => false).group_by(&:assigned_to)
     if dl.present?
       dl.each do |assigned_to, deals|
         if deals.first.assigned_user.present?
            assigned_email = deals.first.assigned_user.email
            full_name = deals.first.assigned_user.full_name
         else
            user = User.where("id=?",assigned_to)
			if user.present?
            assigned_email = user.email
            full_name =  user.full_name
			end
         end
         
         puts "========> sending mail to #{assigned_email}"
         Notification.bulk_lead_notification(assigned_email,full_name,deals).deliver if assigned_to != 0
		 #Notification.bulk_lead_notification(assigned_email,full_name,deals).deliver
         #deals.update_all({:is_csv => false}, {:is_mail_sent => true})
         if deals.present?
           puts "----------------->   updating is_csv and  is_mail_sent   <----------------------"
           Deal.where(id: deals.map(&:id)).update_all(is_csv: false, is_mail_sent: true)
         end
         
         ##for insert or update opportunity         
         dealscon = DealsController.new
         dealscon.insert_opportunities_for_user(deals.first.assigned_user.id)
         
         
       end
     end 
  end 
    
end




