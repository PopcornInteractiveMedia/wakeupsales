module HotLeadAssignment
   require 'digest'
  #include ApplicationHelper

  ##Check and update the token, expiry time etc....
  def insert_or_update_token_info_inbound deal, from=nil
        puts "----------->  inset_or_update_token_info_inbound <-----------------"
        if from == 'api'
            user = get_organization_users_as_per_level(deal.organization,from)
            update_deal_info(deal, from, user, nil,nil) if user.present?
            puts "------- inside api ---------"
        else
          puts "-----------> else of from <--------------------"
          start_process_of_assigning_deal deal
        end
  end

  def start_process_of_assigning_deal deal_id, assigned_to=nil, hot_lead_token=nil, action=nil
        puts "-----------------------............start_process_of_assigning_deal ..... ..........------------------------"
        deal = Deal.find deal_id
        user = get_organization_users_as_per_level deal.organization,'rake', deal.assignee_id , deal.next_priority_id

        if user != "no more user"
           update_deal_info deal, nil, user, next_user='present', action
        else
           puts "---------------else of start processing"
           update_deal_info deal, nil, user=nil, next_user='not-present', action
        end
  end


  ##Find out organization users by priority_label
  def  get_organization_users_as_per_level organization, from=nil,assignee=nil, next_priority=nil
        puts "---------..... -------------"
       if from == 'api'
           user = User.select("`users`.`id`, `users`.`priority_label` ").where("priority_label != ? and organization_id = ?", 0,organization.id).group("`users`.`id`, `users`.`priority_label`").order("`users`.`priority_label`").first
            if user.present?
                  return user
            end
       elsif from == 'rake'
            puts "---------else part of get user organization rake or deny -------------"
            all_users = User.select("`users`.`id`, `users`.`priority_label` ").where("priority_label != ? and organization_id = ?", 0,organization.id).group("`users`.`id`, `users`.`priority_label`").order("`users`.`priority_label`")
              #SELECT `users`.`id`, `users`.`priority_label` FROM `users` WHERE (priority_label != 0 and organization_id = 1) GROUP BY `users`.`id`, `users`.`priority_label` ORDER BY `users`.`priority_label` LIMIT 1
           #all_users = all_users.select{|a| a.assigned_to == assigned_user }.count
          
           current_priority_user = all_users.index(all_users.find { |l| l.id == assignee })
           
           if(next_priority_user = all_users[current_priority_user + 1]).present?  #|| all_users[0] #use a null guard to wrap to the front
             return next_priority_user
           else
            return "no more user"
           end

        end
  end
  
  
  def update_deal_info deal, from=nil, user,next_user, action
      puts "----------> updating the info <----------------"

      if user.present?
          token = (Digest::MD5.hexdigest "#{deal.id}-#{DateTime.now.to_s}")
          if action == 'deny'
              expiry_time = Time.now.utc + 15.minutes              
           else
              expiry_time = (from == 'api') ? deal.created_at + 15.minutes :  deal.token_expiry_time + 15.minutes
           end
           deal.update_attributes :hot_lead_token => token, :token_expiry_time => expiry_time, :next_priority_id =>user.priority_label , :assignee_id => user.id
           puts "--------------> sending mail"
           if(user = User.where("id = ?",deal.assignee_id).first).present?
             #assign_priority_deal_notification(a_email,deals,user_name,assigned_to)
             Notification.assign_priority_deal_notification(user.email,deal,user.full_name,deal.assignee_id).deliver if action != 'deny'

             if action == 'deny'
                   file = File.new("#{Rails.root}/log/deny_hot_lead.log", "a")          
                   file.puts 'Denied deal' + ' ' + "executed on" + ' ' + Time.now.utc.to_s 
                   file.puts "Date:" + Time.now.utc.strftime("%m/%d/%Y").to_s
                   file.puts "denied user---->" + ' :' + user.id.to_s + " First name:" +(user.first_name.present? ? user.first_name : '')
                   file.puts "---------------------------------------> <----------------------------------------------"
                   file.close
             else
                   file = File.new("#{Rails.root}/log/hot_lead_assignment.log", "a")
                   file.puts 'Hot lead assignment' + ' ' + "executed on" + ' ' + Time.now.utc.to_s 
                   file.puts "Date:" + Time.now.utc.strftime("%m/%d/%Y").to_s
                   file.puts "assigned to user---->" + ' :' + user.id.to_s + " First name:" +(user.first_name.present? ? user.first_name : '')
                   file.puts "----------------------------------------> <----------------------------------------------"
                   file.close
             end
           end
      else
          deal.update_attributes :hot_lead_token => nil, :token_expiry_time => nil, :next_priority_id =>nil , :assignee_id => nil
      end
  end
  
  
end
