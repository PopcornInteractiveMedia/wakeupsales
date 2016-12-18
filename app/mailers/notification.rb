class Notification < ActionMailer::Base
  include SendGrid
  include Icalendar
  helper :mailer
  default :from => 'WakeUpSales <no-reply@wakeupsales.com>'
  
  def send_email(to,cc,bcc,subject,msg,file_name,file,frommail='WakeUpSales <no-reply@wakeupsales.com>',activity_id, name)  
    @message  = msg
    @origin_id = activity_id
    @name = name
    @email = to
    if file != ""
      attachments[file_name] = File.read(file) 
    end
    mail(to: to, cc: cc,bcc: bcc, subject: subject, from: frommail)
  end
  
  def send_deal_info(email,name,created_by,title,deal_id)
    @name=name
    @created_user=created_by
    @deal_title=title
    @deal_id = deal_id
    mail(to: email, subject: "WakeUpSales: New deal assigned")
  end
  
  def send_task_info(email,name, created_by, due_date,title,url,type,type_id)
    @name=name
    @created_user=created_by
    @task_due_date=due_date
    @task_title=title
	@task_url=url
    @associated_obj_type=type
    @associated_obj_type_id=type_id
    mail(to: email, subject: "WakeUpSales: New task assigned")
  end
  
  def send_event_info(email, start_date, end_date, title, deal_title, con_email)
#    @name=name
#    @created_user=created_by
#    @task_due_date=due_date
#    @task_title=title
#	@task_url=url
#    @associated_obj_type=type
#    @associated_obj_type_id=type_id
#    mail(to: email, subject: "WakeUpSales: New task assigned")
    
    mail(:to => email, :subject => "WakeUpSales: Invitation for the event") do |format|
       format.ics {
       ical = Icalendar::Calendar.new
       e = Icalendar::Event.new
       e.dtstart = DateTime.strptime(start_date.to_s, '%s')
       e.dtend = DateTime.strptime(end_date.to_s, '%s')
       e.organizer = email
       #e.uid "MeetingRequest"
       e.attendee= ["mailto:"+email.to_s, "mailto:"+con_email.to_s]
       e.summary = title
       #e.description = "Have a long lunch meeting and decide nothing..."
       e.ip_class    = "PRIVATE"
       ical.add_event(e)
       ical.publish
       #ical.to_ical
       render :text => ical.to_ical, :layout => false
      }
    end
  end
  
  def test_mail
     mail(:to => "test@test.com", :subject => "WakeUpSales: Invitation for the event") do |format|
       format.ics {
       ical = Icalendar::Calendar.new
       e = Icalendar::Event.new
       e.dtstart = DateTime.strptime("1406715175", '%s')
       e.dtend   = DateTime.strptime("1406715175", '%s')
       e.organizer = "test@test.com"
       #e.uid "MeetingRequest"
       e.attendee= %w(mailto:test@test.com)
       e.summary = "Meeting to discuss regarding the deal."
       e.description = "Have a long lunch meeting and decide nothing..."
       e.ip_class    = "PRIVATE"
       ical.add_event(e)
       ical.publish
       #ical.to_ical
       render :text => ical.to_ical, :layout => false
      }
    end
  end
  
  def mail_notification_to_betauser(email,link)
    @email = email
    @link = link
    mail(to: email, subject: "WakeUpSales: Verify email")  
  end  
  
   def contact_us_mail(email,name,comment)
     @email = email
     @name = name
     @comment = comment
     mail(to: "support@wakeupsales.com", subject: "WakeUpSales: Contact Us")  
	 
    end  
  
  
  def mail_notification_to_siteadmin(admin_email, user_email)
    @admin_email = admin_email
    @user_email = user_email
    #mail(to: admin_email, subject: "WakeUpSales: A Beta User Registered")  
	mail(to: admin_email, cc: "test@test.com", subject: "WakeUpSales: A Beta User Registered")  
	
  end
  
 def mail_to_admin_api(admin_email, source, link,contact_name, contact_email,contact_phone,initial_note,subject)
    @admin_email = admin_email
    @contact_name =  contact_name
    @contact_email = contact_email
    @contact_phone = contact_phone
    @initial_note = initial_note
    #@source = source
    @source = subject
    @link = link
    #mail(to: admin_email,  subject: "WakeUpSales: A hot lead entered through "+ source)  
      mail(to: admin_email,  subject: "WakeUpSales: Hotlead via "+ subject)  
  
  end  
  
  def mail_notification_for_signup_to_betauser(email, link)
    @email = email
    @link = link
    mail(to: email, subject: "WakeUpSales: Complete Signup Process")
  end  
  
  def bulk_lead_notification assigned_email, name, deals, from=nil
    @email = assigned_email
    @deals = deals
    @name = name
    subject_txt = (from == "reassign" ? "re-assigned" : "assigned")
    mail(to: assigned_email, subject: "WakeUpSales: #{name}, #{deals.count} Deals #{subject_txt} to you")  
  end
  
  def notification_today_task user, tasks, date
     @user = user
     @tasks = tasks     
     mail(to: user.email, subject: "WakeUpSales: #{user.first_name}, Today's tasks #{date}")
  end
  
  def won_deal_notification(a_email,deals,user_name)
     @deal = deals
     @user = user_name
     mail(to:a_email, subject: "WakeUpSales: Cheers a deal has been won")  

    end 
    
    
  def weekly_digest_notification assigned_email, name, deals, timezone, assigned_to, total_deal, dealassigned,frequency
    @email = assigned_email
    @deals = deals
    @name = name
    @day = timezone.strftime("%A").to_s
    @assigned_to = assigned_to
    @total_deal = total_deal 
    @dealassigned = dealassigned
	
    crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
    encrypted_user_id = crypt.encrypt_and_sign(assigned_to)
	@url = (Rails.env == "production" ? "https://wakeupsales.com" : "http://staging.wakeupsales.com") + "/update_weekly_digest?user_id=#{encrypted_user_id}"
    
    #We have listed all of these active deals in the pipeline, which you might need to work on: 
    if total_deal > 10
      @header_txt = "You have #{total_deal} deals assigned to you need attention!"
      @body_txt = "#{@dealassigned} out of #{@total_deal}"
    else
      @header_txt = ""
      @body_txt = "all of these"
    end

    mail(to: assigned_email, subject: "WakeUpSales: #{frequency} Digest Email - #{timezone.strftime('%m').to_s}/#{timezone.strftime('%d').to_s}")
    #mail(to: "ansuman.taria@andolasoft.co.in", subject: "WakeUpSales: Weekly Digest Email - #{timezone.strftime('%m').to_s}/#{timezone.strftime('%d').to_s}")
  end
  
  def assign_priority_deal_notification(a_email,deals,user_name,assigned_to)
     @deal = deals
     @user = user_name
	   crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
	   @encrypted_lead_token = crypt.encrypt_and_sign(@deal.hot_lead_token)
	   @assigned_to = crypt.encrypt_and_sign(assigned_to)
     mail(to:a_email,subject: "WakeUpSales: \'#{@deal.title}\' has been assigned to you")  
     #mail(to: "amit.mohanty@andolasoft.co.in", subject: "WakeUpSales: \'#{@deal.title}\' has been primarily assigned to you")  
   end   
    
  def latest_blog_notification email,contact_id, guid, title, content
    #@email = assigned_email
	puts "latest blog notification========>"
	@guid = guid
    @title = title
	@content = content
    crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
    @encrypted_lead_token = crypt.encrypt_and_sign(contact_id)
    @contact_id = crypt.encrypt_and_sign(contact_id)
    mail(to: email, subject: "Andolasoft Blog: \'#{@title}\'")
  end

  def send_email_to_downloader(name,to)
    @name = name
    mail(to: to, subject: "Free Download WakeUpSales Community Edition")
  end

  def send_email_to_admin(name,email,location)
    @name = name
    @email = email
    @location = location
    mail(to: "support@wakeupsales.org", subject: "Free Download WakeUpSales Community Edition")
  end
end
