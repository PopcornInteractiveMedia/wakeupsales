class LatestBlogNotification
  include Sidekiq::Worker
  
  def perform(guid,title,content,send_all)         
	 puts "========> sending latest blog mail <============"
	 if send_all == true || send_all == "true"
	     deals = Deal.includes(:priority_type).includes(:deals_contacts).where("priority_types.original_id = ?",1).where("contactable_type = ?",'IndividualContact').select("DISTINCT contactable_id").group("contactable_id")
		 if deals.present?
			deals.each do |dl|
				begin
					if dl.deals_contacts.first.contactable.present?
						if dl.deals_contacts.first.contactable.subscribe_blog_mail == true && (!dl.deals_contacts.first.contactable.subscribe_blog_date.present? || (Date.today.to_s != DateTime.parse(dl.deals_contacts.first.contactable.subscribe_blog_date.to_s).strftime('%Y-%m-%d').to_s))
							cnt_email = dl.deals_contacts.first.contactable.email
							cnt_id = dl.deals_contacts.first.contactable.id
							puts "deals contact information =========================="
							p dl.deals_contacts.first.contactable
							Notification.latest_blog_notification(cnt_email,cnt_id,guid,title,content).deliver
							dl.deals_contacts.first.contactable.update_attributes(:subscribe_blog_date=>Time.now)
							SubscribeBlogLog.create(:contact_id => cnt_id, :contact_email => cnt_email, :blog_title => title, :blog_content => content, :status => "success", :error_message =>nil)
						end
					end
				rescue Exception => e
				    my_logger ||= Logger.new("#{Rails.root}/log/subscribe_blog_mail.log")
					my_logger.info("--------parameters--------------at---"+ Time.now.to_s + "-----------")
					my_logger.info(cnt_id)
					my_logger.info(cnt_email)
					my_logger.info(title)
					my_logger.info(e.message)
					my_logger.info("------------------------end------------------------\n")				
					SubscribeBlogLog.create(:contact_id => cnt_id, :contact_email => cnt_email, :blog_title => title, :blog_content => content, :status => "error", :error_message =>e.message)
				end
			end
		 end
	 else
		puts "coming to else latest_blog_notification ================================"
		Notification.latest_blog_notification("ansuman.taria@andolasoft.co.in",207,guid,title,content).deliver
	 end
  end
end