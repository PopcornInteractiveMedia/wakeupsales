module ApplicationHelper
include TasksHelper
include DeviseHelper
require 'net/http'
require 'uri'

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
def qualified_deals_count
  
   count_condition=get_deal_status_count([1,2,3,4,5,6])
   @qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?)", [2]).count
    return @qualified_deals
end
  def new_deals_count(status=[1])
    if(@current_user.is_super_admin? || @current_user.is_admin?)
     deals = @current_user.organization.deals.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)    
    else
     deals = @current_user.all_assigned_deal.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)
    end
    deals.count
  end
  
  def new_deals_three_month(status=[1])
    if(@current_user.is_super_admin? || @current_user.is_admin?)
     deals = @current_user.organization.deals.last_three_months.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status).count
    else
     deals = @current_user.all_assigned_deal.last_three_months.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status).count
    end
    deals
  end
  
  
  
  
  def total_notification_count
      ##TODO uncomment to add attention deal count..
     new_deals_count.to_i + badge_today.to_i + badge_overdue.to_i + qualified_deals_count.to_i #+ attention_deals_count.to_i

  end
  
  def get_deal_status_count(status, user=nil, associated_by=nil)
    #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    query_condition=[]
    if user.present? && associated_by.present? && status.length == 1 && (status.include?1) 
     if associated_by == "created by"
#      deals = user.my_created_deals
      query_condition.where("initiated_by= ? and deals.organization_id = ?",user.id,user.organization_id)
     elsif associated_by == "assigned to"
#      deals = user.all_assigned_deal
      query_condition.where("assigned_to = ? and deals.organization_id = ? ",user.id, user.organization_id)
     end
    else
      if(@current_user.is_super_admin? || @current_user.is_admin?)
#        deals = @current_user.organization.deals
        query_condition.where("is_active=? AND deals.organization_id = ? ", true, @current_user.organization.id)
      elsif !@current_user.is_super_admin? && !@current_user.is_admin?
        if status.length == 1 && (status.include?1)
#          deals = @current_user.all_deals_dashboard
          query_condition.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",@current_user.id,@current_user.id,@current_user.organization_id)
        elsif status.uniq.sort == [1,2,3,4,5,6].uniq.sort
#          deals = @current_user.all_assigned_deal
          query_condition.where("assigned_to = ? and deals.organization_id = ? ",@current_user.id, @current_user.organization_id)
        else
#          deals = @current_user.my_deals
          query_condition.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?",@current_user.id,@current_user.id,@current_user.organization.id)
        end
      end
   end
#    deals.includes(:deal_status).where("deal_statuses.original_id IN (?) and is_active=? ", status, true)
    
    query_condition
  end
  
  def quarter_month_numbers(date)    
    #quarters = [[1,2,3], [4,5,6], [7,8,9], [10,11,12]]
    quarters = [[1], [2], [3], [4]]
    quarters[(date.month - 1) / 3]    
    
  end

  def format_activity_date(date)
    if date == Date.today.strftime("%b %d, %Y")
      "Today"
    elsif date == Date.yesterday.strftime("%b %d, %Y")
      "Yesterday"
    elsif (date > Date.today.strftime("%b %d, %Y") - 7) && (date < Date.yesterday.strftime("%b %d, %Y"))
      "Weekday"
    else
       date.strftime("%b %d, %Y")
    end
  end
  
  def get_priority_color(obj)
    clr="green"
    if obj.priority_id == 1
      clr="red"
    elsif obj.priority_id == 2
      clr="blue"
    end
    clr
  end
  
  def get_deal_status_count_within_four_weeks()
    #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    condition_four_weeks=[]
   if(@current_user.is_super_admin? || @current_user.is_admin?)    
#     deals = @current_user.organization.deals.includes(:deal_status).within_four_weeks.where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)    
     condition_four_weeks.where("deals.created_at >=? AND is_active=? AND (deals.is_public = true and deals.organization_id = ?)", 4.weeks.ago, true, @current_organization.id)
    else
##      deals = @current_user.all_deals.includes(:deal_status).within_four_weeks.where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)
      condition_four_weeks.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",@current_user.id,@current_user.id,@current_organization.id)
#     #deals=deals.where("(deals.assigned_to=? )", @current_user.id) unless @current_user.is_admin?
    end
    
    condition_four_weeks
  end
  
  def get_deal_status_count_statistics(status)
    deals = @current_user.all_assigned_or_created_deals.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)
    deals
  end
  
  ##for leader dashboard  
  def get_deal_status_won_count(user,status,start_date,end_date)
    deals = user.all_assigned_deal.by_range(start_date,end_date).includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)
   
    deals
  end
  


  ##allow to login if siteadmin approves the organization and its users
  def approve_all_users_organization org_email
    org = Organization.find_by_email org_email
    if org.present?
       org.users.update_all(:is_active => true)
    end
  end
  
  ##Disallow to login if siteadmin approves the organization and its users
  def  disapprove_all_users_organization org_email
    org = Organization.find_by_email org_email
    if org.present?
       org.users.update_all(:is_active => false)       
    end
  end
  
  ##Used for profile page
  def get_deal_status_count_user(status, user)

   #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    query_condition=[]
      if(user.is_super_admin? || user.is_admin?)
        query_condition.where("is_active=? AND deals.organization_id = ? ", true, user.organization_id)
      elsif !user.is_super_admin? && !user.is_admin?
        if status.length == 1 && (status.include?1)
          query_condition.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",user.id,user.id,user.organization_id)
        elsif status.uniq.sort == [1,2,3,4,5,6].uniq.sort
          query_condition.where("assigned_to = ? and deals.organization_id = ? ",user.id, user.organization_id)
        else
          query_condition.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?",user.id,user.id,user.organization.id)
        end
     end
    query_condition
  end
  
  ##for report section total deals won for admin  
  def get_deal_status_total_won(status,start_date,end_date)
    deals = @current_user.organization.deals.by_range(start_date,end_date).includes(:deal_status).where("deal_statuses.original_id IN (?) ", status).includes(:deal_moves).order("deal_moves.created_at desc")
   
    deals
  end
  
  def all_org_users
   if @current_user.organization.present?
		@current_user.organization.users.where("invitation_token IS ? and is_active = ?", nil,true).order("first_name").each do |u|
		  if u.id == @current_user.id
			u.first_name="me"
			u.last_name = ""
		  end
		end
	end
  end
  
  def select_all_org_users
    @current_user.organization.users.where("invitation_token IS ? ", nil).order("is_active desc,first_name").each do |u|
      if u.id == @current_user.id
        u.first_name="me"
        u.last_name = ""
      end
    end
  end

  def get_deal_index_status_count(status, user, associated_by)
    query_condition=[]
    if user.present?
       if associated_by == "created by"
        query_condition.where("is_active = ? and initiated_by= ? and deals.organization_id = ?",true,user.id,user.organization_id)
       elsif associated_by == "assigned to"
        query_condition.where("is_active = ? and assigned_to = ? and deals.organization_id = ? ",true,user.id, user.organization_id)
       end
    end
    query_condition
  end
  
  
  def attention_deals_count
    adc=AttentionDeal.select("deal_count").where("user_id=? AND organization_id=?", @current_user.id, @current_organization.id).first
    adc.present? ? adc.deal_count : 0
  end
  
  def date_format(date)
       dt = date.strftime("%Y").to_s == Time.zone.now.year.to_s ? date.strftime("%b %d") : date.strftime("%b %d, %Y")
       dt
  end  
  
  def assigned_to_users
     @c = []
     user = @current_user.organization.users.where("invitation_token IS ? and is_active = ?", nil,true)
     user.each do |a|
        @c << a.email
     end
     return @c
  end  
  
  def current_env
        Rails.env
  end
  
  
  def deal_status_count_last_one_month(in_days= nil)
    #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    condition_four_weeks=[]
   if(@current_user.is_super_admin? || @current_user.is_admin?)    
     if in_days.present?
      if(in_days == "30-Days")
        time = Time.zone.now - 1.month
      elsif(in_days == "60-Days")
        time = Time.zone.now - 2.months
      elsif(in_days == "90-Days")
        time = Time.zone.now - 3.months
      end
     else
      time = Time.zone.now - 1.month
     end
     condition_four_weeks.where('deals.created_at BETWEEN ? and ?',time,Time.zone.now).where("is_active=? AND (deals.is_public = true and deals.organization_id = ?)", true, @current_organization.id)
    else
      condition_four_weeks.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",@current_user.id,@current_user.id,@current_organization.id)
    end
    condition_four_weeks
  end
  

  def check_deal_is_opportunity(deal_id)
        return Proc.new {
          deal = Deal.find deal_id
          unless deal.is_opportunity
              puts "-------deal #{deal.id}"
              if deal.organization.present?
                  won_id = deal.organization.won_deal_status().id
                  if won_id.present?
                        deal.deals_contacts.map { |contact| 
                              if  contact.contactable.present? 
                                  contact.contactable.deals_contacts.each do |dc|
                                  if dc.deal.present?
                                            if dc.deal.deal_status_id == won_id
                                               puts "-----------> found won deals  #{dc.deal.id}"
                                               deal.update_column :is_opportunity, true 
                                               break
                                            end
                                    end
                                  end
                              end
                         }
                   end
               end
           end
         }
  end
  
  def get_image_url path,source=nil   
     # https://www.linkedin.com/company/texas-creative?trk=tyah&trkInfo=tarId%3A1405914736988%2Ctas%3ATexas+Creative%2Cidx%3A1-1-1
      page = Nokogiri::HTML(open(path))
	    #page_html = page.to_html
	    #doc = Nokogiri::HTML::DocumentFragment.parse(page_html)
	    #url = ""
      #@image = doc.search('img')
      begin 
        unless path.include?("/company/")
          img = page.css("img[class='photo']")
        else
          img = page.css("img[class='hero-img']")
        end
        return img[0]["src"]
       rescue
          return  "not_found"
       end
    end
  
  def format_date(date)
    elapsed = Time.now - date
    case elapsed
      when 0..60 then "#{elapsed.to_i} sec#{'s' if elapsed.to_i > 1} ago"
      when 0..60*60 then "#{(elapsed / 60).to_i} min#{'s' if (elapsed / 60).to_i > 1} ago"
      when 60*60..60*60*24 then "#{(elapsed / (60 * 60)).to_i} hour#{'s' if (elapsed / (60*60)).to_i > 1} ago"
      when 60*60*24..60*60*24*2 then "1 day #{(elapsed.to_i - (60*60*24))/(60*60)} hour#{'s' if ((elapsed - 60*60*24)/(60*60)).to_i > 1} ago"
      when 60*60*24..60*60*24*2 then "1 day"
      when 60*60*24*2..60*60*24*7 then "#{(elapsed/(60*60*24)).to_i} days ago"
      when 0..60*60*24*7 then "#{time_ago_in_words(date)} ago"
    else date.strftime("%H:%M %b %d, %Y")
    end
  end
  def send_weekly_digest_mail(deals,assigned_to,set_time_zone,frequency)
    total_assigned_deal = deals.count
   if deals.first.assigned_user.present?
        user = deals.first.assigned_user
        assigned_email = user.email
        full_name = user.full_name
    else
          user = User.where("id=?",assigned_to).first
          if user.present?
                assigned_email = user.email
                full_name =  user.full_name
          end
     end
     assgneddeals = deals.take(10)
     puts "------------>mail sending #{assigned_to} "
     Notification.weekly_digest_notification(assigned_email,full_name,assgneddeals,set_time_zone,user.id,total_assigned_deal, assgneddeals.length,frequency).deliver
     user.update_column :digest_mail_date, set_time_zone
	 @file = File.new("#{Rails.root}/log/digest_mail.log", "a")
	 @file.puts 'Notification for Digest Mail' + ' ' + "executed on" + ' ' + Time.now.to_s
     @file.puts "User ID---->" + ' :' + user.id.to_s + " Email:" + user.email
	 @file.puts "User enable digest mail: " + user.user_preference.weekly_digest.to_s
	 @file.puts "User set frequency: " + user.user_preference.digest_mail_frequency
	 @file.puts "User time now: " + set_time_zone.to_s
     @file.puts "User time zone: " + user.time_zone
     @file.close

  end

end
