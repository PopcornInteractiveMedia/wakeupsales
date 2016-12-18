class SendWeeklyEmail
  include Sidekiq::Worker
  
  def perform(org_id)
    
        #@admin_email = User.where("organization_id=? and admin_type =?",org_id,2)

         #all_deals = Deal.joins([:deal_status,:activities]).select("count(activities.id) activities_count , `deals`.`assigned_to`, `deals`.`id` ").by_is_active.where(organization_id: org_id).where(last_activity_date: 2.week.ago.beginning_of_week..1.week.ago.end_of_week).where("is_remote=0 and deal_statuses.original_id IN (?)", [1,2]).group("`deals`.`assigned_to`, `deals`.`id`").order("deals.assigned_to,activities_count desc")
#         all_deals = Deal.joins([:deal_status,:activities]).select("count(activities.id) activities_count , `deals`.`assigned_to`, `deals`.`id` ").by_is_active.where(organization_id: org_id).where('deals.last_activity_date >= ?', 2.weeks.ago).where('activities.activity_date >= ?', 2.weeks.ago).where("is_remote=0 and deal_statuses.original_id IN (?)", [1,2]).group("`deals`.`assigned_to`, `deals`.`id`").order("deals.assigned_to,activities_count desc")
         all_deals = Deal.joins(:deal_status).select("`deals`.`assigned_to`, `deals`.`id` ").by_is_active.where(organization_id: org_id).where("`deals`.`assigned_to` is not null AND is_remote=0 and deal_statuses.original_id IN (?)", [1,2]).group("`deals`.`assigned_to`, `deals`.`id`").order("`deals`.`assigned_to`, `deals`.`last_activity_date` desc")
           puts "----------> all  deals--------------> "
       deal_ids = []
       assigned_user = ""
       same_record = "false"
       actlimit = 10
       activitycount = 1
       all_deals.each do |deal|
          puts "---------->"
          p activitycount
          p assigned_user
          if (assigned_user == "" || assigned_user == deal.assigned_to) && (activitycount < actlimit)
                assigned_user = deal.assigned_to
                p deal.id
                deal_ids  << deal.id
                p deal_ids
                activitycount = activitycount + 1
                p activitycount
          elsif assigned_user != deal.assigned_to
               ###mail sending part
               puts "------------------> mail sent to #{assigned_user}"
               p deal_ids
               deals = Deal.where(id: deal_ids.uniq)
               total_assigned_deal = all_deals.select{|a| a.assigned_to == assigned_user }.count
                if deals.first.assigned_user.present?
                      user = deals.first.assigned_user
                      assigned_email = user.email
                      full_name = user.full_name
                  else
                        user = User.where("id=?",deal.assigned_to).first
	                      if user.present?
                              assigned_email = user.email
                              full_name =  user.full_name
	                      end
                   end
              Time.zone = user.time_zone #assign time zone as per the user
		   if user.user_preference.weekly_digest == true
			Notification.weekly_digest_notification(assigned_email,full_name,deals,Time.zone.now,assigned_user,total_assigned_deal, activitycount,"Weekly").deliver 
		   end
            puts "##############"
            same_record = "false"
            assigned_user = deal.assigned_to
            deal_ids.clear
            activitycount = 1
            deal_ids  << deal.id
        
          end
       
       end
  end
end

