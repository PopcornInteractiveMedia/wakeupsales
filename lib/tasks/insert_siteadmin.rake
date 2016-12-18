namespace :wus do
  task :insert_siteadmin_to_user => :environment do 
  usr = User.find_by_admin_type 0
    if usr.present?
      puts "---  You have already set up an account for site admin ----"
    else    
      puts "Plz wait....."	
      User.create(:email => "john@example.com",:password => "test1234", :first_name => "Siteadmin", :admin_type=> 0,:confirmation_token=>nil, :confirmed_at=>Time.now)
      puts "--  Successfully created an account for site admin ----"
    end
  end
  
  ##updating the deal country_id as per the first contact's country_id
  task :update_deal_country_id => :environment do
    puts "Starting task to update deal table with the country id"
    Deal.where("country_id is null").find_each do |deal|
      country_id = ((deal_contact=deal.deals_contacts.first).present? && deal_contact.contactable.present? && deal_contact.contactable.address.present?) ? deal_contact.contactable.address.country_id : nil
      puts "updating deal with id #{deal.id} with country id=#{country_id}"
      if country_id.present? && deal.country_id.nil? && deal.update_column(:country_id, country_id)
        puts "successfully updated"
      else
        puts "update failed"
      end
    end
  end
  
  
  ##updating the deal closed_by as per the user who closed the deal
  task :update_closed_by => :environment do
    puts "Starting task to update deal table with the Closed By"
	Organization.find_each do |org|
	    dealStatusid= org.deal_statuses.where('original_id=?',4).first.id
		org.deals.find_each do |dl|
		  dl.deal_moves.each do |dm|
			  if dm && dm.deal_status_id == dealStatusid && dl.update_column(:closed_by, dm.user_id)
				puts "successfully updated with id #{dl.id}"
			  else
				puts "update failed"
			  end
		  end
		  puts "updating deal with id #{dl.id}"
		end
	end
  end
  
  
  ##updating the source id in activity table
  task :insert_source_id => :environment do
    puts "--------------------------------- inserting record"
    Activity.find_each do |activity|
        if activity.activity_type == "Task"
          if activity.activity_status != "Archive"
             record = Task.find activity.activity_id
             if record.present?
              source = record.taskable ? record.taskable.id : nil
             end
          end
        elsif activity.activity_type == "Deal"          
           source = activity.activity_id
        elsif activity.activity_type == "DealMove"
           record = DealMove.find activity.activity_id
           if record.present?
             source = record.deal ? record.deal.id : nil
           end
        elsif activity.activity_type == "Note"
           record = Note.find activity.activity_id
           if record.present?
             unless record.notable_type == "DealMove"
                source = record.notable ? record.notable.id : nil
             else
                source = record.notable.deal ? record.notable.deal.id : nil
             end
           end
         elsif activity.activity_type == "DealsContact"
           record = DealsContact.find activity.activity_id
           if record.present?
             source = record.deal_id ? record.deal_id : nil
           end
        end
        unless source.nil? || source.blank?
          activity.update_column(:source_id, source)
          p activity.id
        end
    end 
  end
  
  ##inserting deals contacts to activity table
  task :insert_deal_contact_to_activity => :environment do
     DealsContact.find_each do |dl|
          Activity.create(:organization_id => dl.organization_id,	:activity_user_id =>dl.deal.initiated_by,:activity_type=> dl.class.name, :activity_id => dl.id, :activity_status => "Add",:activity_desc=>dl.contactable.present? ? (dl.contactable.full_name ? dl.contactable.full_name : "") : "",:activity_date => dl.created_at, :is_public => true, :source_id => dl.deal_id)
          p Activity.count
     end
  end
  
  #update deals comments
  task :update_deal_comments_from_note =>  :environment do
    Deal.all.each do |dl|
     ltdeal= Note.where("notable_type=? and notable_id = ?", "Deal", dl.id).last
     if ltdeal and dl.comments.nil? and dl.update_column(:comments,ltdeal.notes)
       puts "comments successfully updated.... Deal -" + dl.id.to_s
     else
       puts "update failed... Deal -" + dl.id.to_s
     end
   end
  end
  
  ##updating is_public if null
  task :insert_is_public_to_deal => :environment do
    Deal.where("is_public is null").find_each do |deal|
      if deal.update_column(:is_public,true)
          puts "successfully updated"
      else
        puts "update failed"
      end
    end
  end
  
  ##inserting activity to contact activity table
  
  task :insert_activity_contact => :environment do
      puts "-------   inserting past activity to contact activity   -----------------------"
      Activity.find_each do |activity|
          case activity.activity_type
          
          when "Note"
              puts "-------------------inside note"
              record = Note.where :id => activity.activity_id
             
              if record.present?
                 record = record.first
                 puts "------------note-------------------- #{record.id}"
                org_id = activity.organization_id
                if record.notable_type == "CompanyContact" || record.notable_type == "IndividualContact"
                  contactable_id = record.notable.id
                  contactable_type = record.notable_type
                  ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
                end
               end
              
           when "Task"
              puts "-------------------inside task"
              record = Task.where :id => activity.activity_id
              
              if record.present?
                record = record.first
                puts "------------task-------------------- #{record.id}"
                org_id = activity.organization_id
                
                if record.taskable.present?
                  if record.taskable.class.name == "CompanyContact" || record.taskable.class.name == "IndividualContact"
                    contactable_id = record.taskable.id
                    contactable_type = record.taskable.class.name
                    ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
                  end
                end
              end
            
            when "Deal"
              puts "-------------------inside deal"
              record = Deal.find activity.activity_id
              
              if record.present?
                puts "----------deal---------------------- #{record.id}"
                org_id = activity.organization_id
                record.deals_contacts.each do |c|
				 if c.contactable.present?
                  contactable_id = c.contactable.id
                  contactable_type = c.contactable.is_individual? ? "IndividualContact" : "CompanyContact"
                  ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
				 end
                end
              end
              
              when "CompanyContact"
                puts "-------------------inside compcontact"
                record = CompanyContact.find activity.activity_id
                if record.present?
                    org_id = activity.organization_id
                    contactable_id = record.id
                    contactable_type = record.class.name
                    ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)                 
              end
              
              when "IndividualContact"
                puts "-------------------inside indiv"
                record = IndividualContact.find activity.activity_id
                if record.present?
                  org_id = activity.organization_id
                  contactable_id = record.id
                  contactable_type = record.class.name
                  ActivitiesContact.create(:organization_id => org_id, :activity_id=> activity.id,:contactable_type=>contactable_type,:contactable_id=> contactable_id)
              end
        end
      end
     puts "------------- #{ActivitiesContact.count}   ---------------"
  end
  
  ##inserting last activity date  
  task :insert_last_activity => :environment do
     Deal.find_each do |deal|  
       puts "--------------------------Deal --- #{deal.id}"
       activity= deal.activities.last
       last_activity= activity.present? ?  activity.activity_date : deal.updated_at
       deal.update_column :last_activity_date,  last_activity
     end
  end
  
##inserting last activity date  
  task :update1_last_activity => :environment do
     Deal.limit(160).order("id desc").each do |deal|  
       puts "--------------------------Deal --- #{deal.id}"
       activity= deal.activities.last
       last_activity= activity.present? ?  activity.created_at : deal.updated_at
       deal.update_column :last_activity_date,  last_activity
     end
  end
  
  
  ##inserting last activity date  
  task :insert_last_activity_is_null => :environment do
     Deal.where("last_activity_date is null").each do |deal|  
       puts "--------------------------Deal --- #{deal.id}"
       activity= deal.activities.last
       last_activity= activity.present? ?  activity.activity_date : deal.updated_at
       deal.update_column :last_activity_date,  last_activity
     end
  end
  
 ##Update Authentication token for organization
  task :update_auth_token_of_organization => :environment do 
    Organization.where("auth_token is null").find_each do |org|
	  auth_token=Digest::MD5.hexdigest(org.email.to_s+org.id.to_s+Time.now.to_s)
	  
      if org.update_attribute(:auth_token, auth_token)
          puts "successfully updated org:"+ org.id.to_s + " and authtoken: " + auth_token.to_s
      else
        puts "update failed"
      end
    end
  end  
  
  ##inserting last activity date  
  task :notification_for_today_task => :environment do
        User.where("invitation_token IS ? and is_active = ?", nil,true).each do |user|     
         if user.organization.present?
           all_tasks = user.organization.tasks 
           if all_tasks.count > 0
             if user.time_zone
                Time.zone = user.time_zone #assign time zone as per the user
                if user.task_date && (user.task_date.strftime("%Y/%m/%d") != Time.zone.now.strftime("%Y/%m/%d"))
                   tasks = all_tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d")).where("(tasks.assigned_to=?)", user.id)                   
                   if tasks.count  > 0
                     if (Time.zone.now.strftime("%H").to_s == "06") 
                       #puts "user----- #{user.id}"
                       @file = File.new("#{Rails.root}/log/today_task.log", "a")
                       @file.puts 'Notification for today task to users' + ' ' + "executed on" + ' ' + Time.zone.now.to_s 
                       @file.puts "Date:" + Time.zone.now.strftime("%m/%d/%Y").to_s
                       @file.puts "user---->" + ' :' + user.id.to_s + " First name:" +(user.first_name.present? ? user.first_name : '')
  	                   @file.close
                       Notification.notification_today_task(user,tasks,Time.zone.now.strftime("%m/%d")).deliver    
                       user.update_column :task_date, Time.zone.now
                     end
                   end
                 elsif user.task_date.nil? && user.task_date.blank?
                    tasks = all_tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d")).where("(tasks.assigned_to=?)", user.id)
                    if tasks.count  > 0                     
                     if (Time.zone.now.strftime("%H").to_s == "06") 
                       #puts "user----- #{user.id}"
                       @file = File.new("#{Rails.root}/log/today_task.log", "a")
                       @file.puts 'Notification for today task to users' + ' ' + "executed on" + ' ' + Time.zone.now.to_s 
                       @file.puts "Date:" + Time.zone.now.strftime("%m/%d/%Y").to_s
                       @file.puts "user---->" + ' :' + user.id.to_s + " First name:" +(user.first_name.present? ? user.first_name : '')
  	                   @file.close
                       Notification.notification_today_task(user,tasks,Time.zone.now.strftime("%m/%d")).deliver    
                       user.update_column :task_date, Time.zone.now
                     end
                   end
                end
             end
           end
         end
      end
  end
  
    ##Removing multiple notes from activity table
  
  task :delete_multiple_notes => :environment do
     #Note.find_each do |note|  
	 Note.limit(1000).order("id desc").each do |note| 
       act =Activity.where("activity_type=? and activity_id = ?", "Note", note.id)
       puts "$$$$$$$$$$$$$$$$$$$$$$$$$$"
       p act
       if act.count > 1
        act.each_with_index do |item, index|
          puts "##########################"
          p item.id
          #ss
          if index == 0
              puts "#### do nothing ##########"
          else
             puts "#####################"
             p index
             
             @note_act = Activity.find(item.id)
             @note_act.destroy
          end
        end
       end
     end
  end 
   
   ##Update latest task type in deals table
  task :update_latest_task => :environment do
     Deal.find_each do |d|
      puts "###################################"
      if (l_type=d.tasks.where("is_completed = 0").last).present?
      
       p d.update_column(:latest_task_type_id, l_type.task_type_id)
      end
     end
  end 
  
 ##Insert contact info into deals table
  
  task :insert_contact_info => :environment do
     Deal.find_each do |d|
      begin 
     
     
        puts "======>  #{d.id} "
        name = (d.deals_contacts.first.contactable.present? ? d.deals_contacts.first.contactable.full_name : "")
        id = (d.deals_contacts.first.present? ? d.deals_contacts.first.contactable_id : "")
        type = (d.deals_contacts.first.contactable.is_company? ? "company_contact" : "individual_contact")
        phone = (d.deals_contacts.first.contactable.present? && d.deals_contacts.first.contactable.phones.first.present? ? d.deals_contacts.first.contactable.phones.first.phone_no : "")
        email = (d.deals_contacts.first.contactable.present? ? d.deals_contacts.first.contactable.email : "")
        comp_desg = (d.deals_contacts.present? &&  d.deals_contacts.first.contactable.present? && d.deals_contacts.first.contactable.is_company? ? "" : d.collect_company_designaion)
        
        loc= (d.deals_contacts.first.contactable.present? && !d.deals_contacts.first.contactable.address.nil? ? d.deals_contacts.first.contactable.address.city : '')
        
        @s = d.contact_info = {"name"=>name,"id"=>id,"type"=> type,"phone"=>phone,"email"=>email,"comp_desg"=>comp_desg,"loc"=>loc}
        
        
       d.update_column(:contact_info,@s.to_json)

       p d.contact_info
     
   rescue Exception => e 
     my_logger ||= Logger.new("#{Rails.root}/log/DealContactInfo.log")
     my_logger.info("--------parameters--------------at---"+ Time.now.to_s + "-----------")
     my_logger.info(e.message)
     my_logger.info("------------------------end------------------------\n")

   end  
  end    
 end

  
  desc "Updating stage move date in the deal table"
  task :updating_deal_stage_date_for_deal => :environment do
    Deal.find_each do |deal|
      puts "Updating the deal##{deal.id} stage move date"
      if (dm=deal.deal_moves.last).present?
        puts "Updating from deal.deal_moves.last id#{dm.id}"
        p deal.update_column(:stage_move_date,  deal.deal_moves.last.created_at)
      else
        puts "Since it is new deal update with deal created_at"
        p deal.update_column(:stage_move_date, deal.created_at)
      end
    end
  end
  
  
  desc "Updating the is_customer in individual contact of won deals"
  task :updating_is_customer_individual_contact => :environment do
      ids = []
      Organization.find_each do |org|
            puts "Oranganization ===>  #{org.id}"
            if (deals = org.deals.where(:deal_status_id=>org.won_deal_status().id)).first.present?
                      deals.each do |deal|
                          puts "====Deal=====> #{deal.id}"
                          deal.deals_contacts.map { |contact| 
                              if  contact.contactable.present? && contact.contactable.is_individual?
                                  puts "----individual contact------> #{contact.contactable.id}  <-------------"
                                  ids << contact.contactable.id
                              end
                          }
                      end
               
            end
      end
      if ids.present?
          puts "===============> updating the records"
          IndividualContact.where(id: ids.uniq).update_all(is_customer: true)
      end
  end
  
 task :insert_old_note_attachment => :environment do
     Note.find_each do |d|
      puts "#################################"
      if d.attachment_file_name.present?
       puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
       p d.id
       NoteAttachment.create(:note_id=>d.id,:attachment_file_name=>d.attachment_file_name,:attachment_content_type=>d.attachment_content_type,:attachment_file_size=>d.attachment_file_size,:attachment_updated_at=>d.attachment_updated_at)
       #NoteAttachment.create(:note_id=>d.id,:attachment=>d.attachment)
      end
     end
  end      

  task :update_is_opportunity_deal => :environment do
  include ApplicationHelper
     Deal.find_each do |d|
          deal_is_opportunity = check_deal_is_opportunity(d.id)
          deal_is_opportunity.call()
     end
  end    
  
   desc "Moving deal tags into tags and taggings"
  task :move_deal_tags_into_tags_and_taggings => :environment do
    puts "update_deal_tags_into_tags_and_taggings"
    Deal.select("id,tags as all_tags ").find_each do |d|
      if d.all_tags.present?
        puts "=====Deal==> #{d.id}"
        tags_convert = d.all_tags.strip.chop.gsub('/',',')
        tags_convert.split(',').each do |ta|
          
          p d.all_tags
          str_tag = ta.strip
          if str_tag.present? 
              tag = ActsAsTaggableOn::Tag.find_by_name(str_tag)
          else
              tag = nil
          end
          if(tag.present?)
            puts "------------------ Updated existing tags ------------------"
            ActiveRecord::Base.connection.execute("update tags set taggings_count=#{tag.taggings_count} where tags.id =#{tag.id};")
            ActsAsTaggableOn::Tagging.new(:tag_id => tag.id,:taggable_id => d.id, :taggable_type => 'Deal', :context => 'tags').save
          elsif str_tag.present?
            puts "------------------ Creating new tags ------------------"
            new_tag = ActsAsTaggableOn::Tag.new(:name => str_tag)
            if new_tag.save!
                  ActsAsTaggableOn::Tagging.new(:tag_id => new_tag.id,:taggable_id => d.id, :taggable_type => 'Deal', :context => 'tags').save
            else
                 my_logger ||= Logger.new("#{Rails.root}/log/Deal_tag.log")
                 my_logger.info("--------unable to save taggings for Deal--" + d.id + "-----------")
                 my_logger.info()
                 my_logger.info("------------------------end------------------------\n")
            end
            
            
          end
        end
      end
    end
  end  
  
  desc "Update tagger into taggings"
  task :update_tagger_in_taggings => :environment do
    ActsAsTaggableOn::Tagging.find_each do |tag|
      begin 
            puts "-----> tag #{tag.id}"
            if tag.taggable.present? && tag.taggable.organization.present?
               tag.update_attributes(:tagger=> tag.taggable.organization)
            end
      rescue Exception => e 
           my_logger ||= Logger.new("#{Rails.root}/log/TaggingsError.log")
           my_logger.info("--------parameters--------------at---"+ Time.now.to_s + "-----------")
           my_logger.info(e.message)
           my_logger.info("------------------------end------------------------\n")
        end  
       
    end
  end
  
  
  ## Weekly Digest email
  task :weekly_digest_email => :environment do
    include ApplicationHelper
      dl = Deal.joins(:deal_status).by_is_active.where(organization_id: 1).where("`deals`.`assigned_to` is not null AND is_remote=0 and deal_statuses.original_id IN (?)", [1,2]).order("last_activity_date desc").group_by(&:assigned_to)
       if dl.present?
          puts "-------------> deal present"
          dl.each do |assigned_to, deals|
              puts "#{assigned_to} assigned to"
            if(user = User.where("id=?",assigned_to).first).present?
              if user.time_zone
                Time.zone = user.time_zone #assign time zone as per the user
                if (user.user_preference.weekly_digest == true)
                  if (user.user_preference.digest_mail_frequency == "daily")
                    if ((!user.digest_mail_date.present?) || (user.digest_mail_date.present? && Date.parse(user.digest_mail_date).strftime("%Y/%m/%d") != Time.zone.now.strftime("%Y/%m/%d")))
                      if (Time.zone.now.strftime("%H").to_s == "06")
                        send_weekly_digest_mail(deals,assigned_to,Time.zone.now,"Daily")
                      end
                    end
                  elsif (user.user_preference.digest_mail_frequency == "weekly")
                    if ((!user.digest_mail_date.present?) || (user.digest_mail_date.present? && Date.parse(user.digest_mail_date).strftime("%Y/%m/%d") != Time.zone.now.strftime("%Y/%m/%d")))
                      if (Time.zone.now.strftime("%A").to_s == "Monday" && Time.zone.now.strftime("%H").to_s == "06")
                        send_weekly_digest_mail(deals,assigned_to,Time.zone.now,"Weekly")
                      end
                    end
                  elsif (user.user_preference.digest_mail_frequency == "monthly")
                    if ((!user.digest_mail_date.present?) || (user.digest_mail_date.present? && Date.parse(user.digest_mail_date).strftime("%Y/%m/%d") != Time.zone.now.strftime("%Y/%m/%d")))
                      if (Time.zone.now.strftime("%d").to_s == "01" && Time.zone.now.strftime("%H").to_s == "06")
                        send_weekly_digest_mail(deals,assigned_to,Time.zone.now,"Monthly")
                      end
                    end
                  end ## check user digest mail frequency
                end ## check user active weekly digest
              end ##if user.time_zone
           end
         end ##dl end
      end
  end


  task :hot_lead_assignment => :environment do  
     include HotLeadAssignment
     
     Deal.where("hot_lead_token is NOT NULL and is_remote = ?",true).find_each do |deal|
           puts "----------->   inside rake task   <------------------"
           p deal.id
           if (deal.token_expiry_time.strftime("%Y-%d-%m %H:%M") == Time.now.strftime("%Y-%d-%m %H:%M"))
              start_process_of_assigning_deal deal.id, deal.assignee_id, deal.hot_lead_token
           end
     end
  end
  
  task :update_contact_image_linkedin => :environment do  
       require 'net/http'
       require 'uri'
       require 'nokogiri'
       require 'open-uri'
       include ApplicationHelper
       
       IndividualContact.where("linkedin_url is NOT NULL").find_each do |contact|
         if contact.linkedin_url.present?
          begin
             puts "-----------> individual contact  #{contact.id} <--------------"
             social_img_url = get_image_url contact.linkedin_url
             p social_img_url
             if social_img_url != "not_found"
              contact_image = URI.parse(social_img_url)
              contact.update_attribute :contact_image, contact_image
             end
             ss
          rescue => e
              puts "----error"
              p contact.id
              my_logger ||= Logger.new("#{Rails.root}/log/linkedin_image.log")
              my_logger.info("--------Executed------------on---"+ Time.now.to_s + "-----------")
              my_logger.info(contact.id)
              my_logger.info(e.message)
              my_logger.info("------------------------end------------------------\n")
          
          end
         end
       end
  end

end
