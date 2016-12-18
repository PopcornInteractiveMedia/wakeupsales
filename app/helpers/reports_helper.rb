module ReportsHelper

  def startdate_enddate_range quarter
      if(quarter == "1")
        start_date = DateTime.new(Time.zone.now.year,1)
        end_date = DateTime.new(Time.zone.now.year,3)     
      elsif(quarter == "2")
        start_date = DateTime.new(Time.zone.now.year,4)
        end_date = DateTime.new(Time.zone.now.year,6)     
      elsif(quarter == "3")
        start_date = DateTime.new(Time.zone.now.year,7)
        end_date = DateTime.new(Time.zone.now.year,9)     
      elsif(quarter == "4")
        start_date = DateTime.new(Time.zone.now.year,10)
        end_date = DateTime.new(Time.zone.now.year,12)     
      end
      return start_date, end_date
  end

  ##for activity count in leader dashboard
  def get_user_activity_count_for_leaderboard(user, start_date, end_date)
     ##start_date = DateTime.new(Time.zone.now.year,10)
     ##end_date = DateTime.new(Time.zone.now.year,12)  
     # activities=Task.find_by_sql("select count(*) count , created_by from (select id,'Deal' as name,created_at,initiated_by created_by from deals where organization_id = #{user.organization.id}  AND initiated_by = #{user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}'
    #UNION ALL
    #(select id,'Contact' as name,created_at,created_by from contacts where organization_id = #{user.organization.id} AND created_by = #{user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    #UNION ALL
    #(select id,'DealMove' as name,created_at,created_by from notes where notable_type = 'DealMove' and organization_id =  #{user.organization.id} AND created_by = #{user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    #UNION ALL
    #(select id,'Task' as name,created_at,created_by from tasks where organization_id = #{user.organization.id} AND created_by = #{user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    #UNION ALL
    #(select id,'Task' as name,updated_at as created_at,assigned_to created_by from tasks where is_completed=1 and organization_id =  #{user.organization.id}  AND assigned_to = #{user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    #UNION ALL
    #(select id,'Note' as name,created_at,created_by from notes where organization_id =  #{user.organization.id} AND created_by = #{user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
	#UNION ALL
   # (select id,'Mail' as name,created_at,mail_by created_by  from mail_letters where organization_id =  #{user.organization.id} AND mail_by = #{user.id}  AND created_at BETWEEN '#{start_date}' AND '#{end_date}')) activities

#group by created_by order by count(*) desc")
 #   activities
    activities=user.activities.by_range(start_date,end_date).count
    activities
  
  end






end
