require 'google/api_client'
require 'chronic'
class Task < ActiveRecord::Base
  belongs_to :organization
  belongs_to :task_type
  belongs_to :taskable, :polymorphic => true
  belongs_to :initiator, :class_name=>"User",:foreign_key=>:created_by
  belongs_to :priority_type, :foreign_key => "priority_id" #,:class_name=>"TaskPriorityType"
  belongs_to :user, :foreign_key => "assigned_to"
  belongs_to :deal
  belongs_to :individual_contact
  belongs_to :company_contact
  attr_accessible :assigned_to, :deal_id, :due_date,:organization_id,
                  :priority_id, :title, :task_type_id, :mail_to, :taskable_id, :taskable_type,
                  :is_completed, :task_note,:created_at,:created_by, :recurring_type, :rec_end_date,
                  :parent_id, :is_event, :event_end_date, :notify_email
  attr_accessor :notify_email

  #after_create :send_email,:inser_activity_table
  after_save :insert_update_activity,:update_latest_task_type, :insert_in_google_calendar

                  
   scope :by_is_completed, lambda {where("is_completed = ?", true)}
   scope :not_completed, lambda {where("is_completed = ?", false)}
   scope :in_prev_week, lambda{ where(:created_at => 1.week.ago.beginning_of_week..1.week.ago.end_of_week) }
   scope :in_current_week, lambda{ where(:created_at => Date.today.beginning_of_week..Date.today.end_of_week) }
   scope :by_range, lambda{ |start_date, end_date| where(:created_at => start_date..end_date) }
   scope :last_three_months, lambda{ where('tasks.created_at >= ?', 3.months.ago)}  
   scope :by_name, lambda{ |name| includes(:task_type).where("task_types.name = ?", name) }
   
  #include Tire::Model::Search
  #include Tire::Model::Callbacks
  
  def self.task_list(user, task_type, taskable=nil, limit=nil,task_type_info=nil)
#    task_log=Logger.new("log/task_list.log")
#    user=User.find user if user.present?
    tasks=[]
      query_condition=[]
      org=user.organization if user.present?
      query_condition.where("tasks.organization_id=?", org.id) if user.present? && org.present?
#    task_log.info "time now"
#    task_log.debug Time.zone.now.strftime("%Y/%m/%d")
    if(taskable.nil?)
#      task_log.info "taskable is nil"
#      if tasks.present? 
# if dashboard == true
#          query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id)
#        else !(user.is_admin? || user.is_super_admin?)
#          query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id)
#        end
	      #query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) #unless (user.is_admin? || user.is_super_admin?)
        #order_by="due_date DESC,priority_id"
        order_by="due_date ASC"
        case task_type
          when "all"
            order_by="due_date DESC"

          when "today"
#            task_log.info "task type is today"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "overdue"
#            task_log.info "task type is overdue"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "upcoming"
#            task_log.info "task type is upcoming"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date ASC,priority_id"
            order_by="due_date ASC"
          when "completed"
#            task_log.info "task type is completed"
            query_condition.where("is_completed=?", true)
            #order_by="updated_at DESC"
            order_by="due_date DESC"
        end
      if task_type_info.present?
         query_condition.where("task_types.name=?",task_type_info)
        end
#      end
      tasks=includes(:initiator).includes(:user).includes(:task_type).includes(:priority_type).where(query_condition).order(order_by).limit(limit)
    else

    
#      tasks=taskable.tasks.order("due_date DESC,priority_id").limit(limit)
#      task_log.info "taskable is #{taskable.class.name}"
#      if tasks.present?
        if user.present?
          #query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) unless (user.is_admin? || user.is_super_admin?)
        end
         #order_by="tasks.due_date DESC,tasks.priority_id"
         order_by="due_date DESC"
        case task_type
          when "today"
#            task_log.info "task type is today"
            query_condition.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", Time.zone.now.strftime("%Y/%m/%d"))
            query_condition.where("is_completed=?", false) unless taskable.class.name == "Contact"
            order_by="due_date ASC"
          when "overdue"
#            task_log.info "task type is overdue"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "upcoming"
#            task_log.info "task type is upcoming"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "completed"
#            task_log.info "task type is upcoming"
            query_condition.where("is_completed=?", true)
            #order_by="tasks.updated_at DESC"
            order_by="due_date DESC"
        end
#      end
      tasks=taskable.tasks.includes(:taskable).includes(:initiator).includes(:user).includes(:task_type).includes(:priority_type).where(query_condition).order(order_by).limit(limit)
    end
    tasks
  end
  
def self.todays_task(user) 
query_condition=[]
	org=user.organization if user.present?
	query_condition.where("tasks.organization_id=?", org.id) if user.present? && org.present?
	query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) 
	query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))	  
	 order_by="due_date ASC"
where(query_condition).order(order_by)

end
  def self.task_list_dashboard(user, task_type, taskable=nil, limit=nil,task_type_info=nil)
#    task_log=Logger.new("log/task_list.log")
#    user=User.find user if user.present?
    tasks=[]
      query_condition=[]
      org=user.organization if user.present?
      query_condition.where("tasks.organization_id=?", org.id) if user.present? && org.present?
	  query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) 

       #order_by="due_date DESC,priority_id"
       order_by="due_date ASC"
        case task_type
          when "today"
#            task_log.info "task type is today"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "overdue"
#            task_log.info "task type is overdue"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "upcoming"
#            task_log.info "task type is upcoming"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date ASC,priority_id"
            order_by="due_date ASC"
          when "completed"
#            task_log.info "task type is completed"
            query_condition.where("is_completed=?", true)
            #order_by="updated_at DESC"
            order_by="due_date DESC"
        end
      if task_type_info.present?
         query_condition.where("task_types.name=?",task_type_info)
        end

      tasks=includes(:initiator).includes(:user).includes(:task_type).includes(:priority_type).where(query_condition).order(order_by).limit(limit)
   
  end
  
def update_latest_task_type
  if(d=self.deal).present? && self.is_completed = true 
     t_type =(t=d.tasks.where("is_completed=?",false).last).present? ? t.task_type_id : nil
     d.update_column(:latest_task_type_id,t_type)
  end
 end



def insert_in_google_calendar
  puts "==========================="
  if initiator.token.present?
    @event = {
      'summary' => self.title,
      #'description' => self.description,
      'location' => 'Location',
      'start' => { 'dateTime' => Chronic.parse(Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
      'end' => { 'dateTime' => Chronic.parse(self.event_end_date.present? ? Time.zone.at(self.event_end_date.to_i).strftime("%Y-%m-%d at %I:%M%P") : Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
    }
    client = Google::APIClient.new(:application_name => 'WakeUpSales',:application_version => '1.0.0')
    client.authorization.access_token = initiator.token
    service = client.discovered_api('calendar', 'v3')
    puts "++++++++++++++++++++++++++"
    p @set_event = client.execute(:api_method => service.events.insert,
          :parameters => {'calendarId' => initiator.email, 'sendNotifications' => true},
          :body => JSON.dump(@event),
          :headers => {'Content-Type' => 'application/json'})
  end
end
 
def send_email
  #if (user.email_notification.nil?) || (user.email_notification && user.email_notification.task_assign == true && user.email_notification.donot_send == false)
    #Notification.send_task_info(user, initiator.full_name, self, self.taskable).deliver 
    #task_for_deal=false
    deal_contact_id=nil
    deal_title=""
    if(d=self.deal).present?
     d.update_column(:latest_task_type_id,self.task_type_id)
     deal_title=d.title
     #task_for_deal=true
     dc=d.deals_contacts.first
     contact=dc.contactable
     deal_contact_id=dc.id if dc.present?
    end
    email = user.email
    name = user.full_name
    formated_due_date = self.due_date.in_time_zone(user.time_zone).strftime("%a %d %b %Y @ %H:%M")
#    formated_event_end_date= self.event_end_date.in_time_zone(user.time_zone)
    event_start_date= self.due_date.in_time_zone(user.time_zone).to_i if self.due_date.present?
    event_end_date = self.event_end_date.in_time_zone(contact.time_zone).to_i if self.event_end_date.present?
    title = self.title
	  url = self.get_url
    type = self.taskable.class.name
    type_id = self.taskable.id
     puts "+++============================================="
    #p is_event
    p notify_email
    #p is_event || notify_email == "1"
    puts "+++============================================="
    #if is_event || notify_email == "1"
	if notify_email == "1"
     SendEmailNotification.perform_async(email,name,initiator.full_name,formated_due_date,title,url,type,type_id, is_event, event_start_date, event_end_date, deal_contact_id, deal_title, due_date)
    end

    
  #end
  end
  
  def inser_activity_table
    de_c = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.created_by,:activity_type=> "Task", :activity_id => self.id, :activity_status => "Create",:activity_desc=>self.get_title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.deal_id)
    de_a = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.assigned_to,:activity_type=> "Task", :activity_id => self.id, :activity_status => "Assign",:activity_desc=>self.get_title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.deal_id)
    ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_a.id,:contactable_type=>self.taskable_type,:contactable_id=> self.taskable_id)
    ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_c.id,:contactable_type=>self.taskable_type,:contactable_id=> self.taskable_id)
    dl = Deal.find self.deal_id
    dl.update_column :last_activity_date,  de_a.activity_date  
  end
  
  def insert_update_activity
    Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.created_by,:activity_type=> "Task", :activity_id => self.id, :activity_status => self.is_completed? ? "Complete" : "Update" ,:activity_desc=>self.get_title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.deal_id)
  end
  
  def get_title
    (self.taskable ? self.taskable.title : "" ) + " / " + self.title
  end
  
  def outcome
    self.task_note
  end
  def get_url
    if self.taskable.present?
      self.taskable.class.name == "Deal" ? "/leads/"+ self.taskable.id.to_s : (self.taskable.class.name == "CompanyContact" ? "/company_contact/"+ self.taskable.id.to_s : "/individual_contact/"+ self.taskable.id.to_s)
    end
  end
  
  # mapping do
  #    indexes :image_url
  #    indexes :initiator_name
  #    indexes :assigned_user_name
  #    indexes :taskable_title
  #    indexes :taskable_name
  #    indexes :taskable_id
  #  end
  
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
      :methods   => [:image_url, :initiator_name, :assigned_user_name, :taskable_title, :taskable_name, :taskable_id]
    )
  end
  
  def image_url
    #if initiator.image.present?
    #  initiator.image.image.url(:icon)
    #else
    #  "/assets/no_user.png"
    #end
    "#{ENV['cloudfront']}/assets/tasks_small.png"
  end
  
  
  def initiator_name
    initiator.present? ? initiator.full_name : ""
  end
  
  def assigned_user_name
    user.present? ? user.full_name : "Not Available"
  end
  def assigned_user_first_name
    user.present? ? user.first_name : "Not Available"
  end
  
  def taskable_title
    taskable.present? ? taskable.title : ""
  end  
  
  def taskable_name
    taskable.present? ? taskable_type : ""
  end
  
  
  def taskable_id
    taskable.present? ? taskable.id : ""
  end
  
   def self.active_multi_filter_report(params)
    
    if(params[:q] == "1")
      start_date = DateTime.new(params[:y].to_i,1,1)
      end_date = DateTime.new(params[:y].to_i,3,31)     
    elsif(params[:q] == "2")
      start_date = DateTime.new(params[:y].to_i,4,1)
      end_date = DateTime.new(params[:y].to_i,6,30)     
    elsif(params[:q] == "3")
      start_date = DateTime.new(params[:y].to_i,7,1)
      end_date = DateTime.new(params[:y].to_i,9,30)     
    elsif(params[:q] == "4")
     start_date = DateTime.new(params[:y].to_i,10,1)
     end_date = DateTime.new(params[:y].to_i,12,31)     
    end
    query=""
     if params[:assigned_to] != "" && (start_date.present? && end_date.present?)
      #query += " and "if query.present?
      query += "tasks.assigned_to=#{params[:assigned_to]}"
      
      query += " and " if query.present?      
      
      query += "`tasks`.`created_at` BETWEEN '#{start_date}' AND '#{end_date}'"
      
     else
       query += "tasks.assigned_to=#{params[:assigned_to]}"
     
      
    end
    
    
    
    
    
    where(query)
   end
  
  def self.active_multi_filter_usage_summery(params) 
      query=""
      if params[:t_type] != ""
           query += "tasks.task_type_id=#{params[:t_type]}"
      end
      
      if params[:assigned_to] != ""
      query += " and "if query.present?
      query += "tasks.assigned_to=#{params[:assigned_to]}"
     end
    
      where(query).last_three_months
  end

  def self.active_multi_filter(params)
#  deal_type: params[:deal_type], asg_to: params[:asg_to], task_type: params[:task_type] , task_status: params[:task_status
    query=""
    d_type=false
    if params[:deal_type].present? && params[:deal_type] != ""
      d_type=true
      query += "deals.deal_status_id=#{params[:deal_type]}"
    end
    if params[:asg_to].present? && params[:asg_to] != ""
      query += " and "if query.present?
      query += "tasks.assigned_to=#{params[:asg_to]}"
    end
    if params[:task_type].present? && params[:task_type] != ""
      query += " and "if query.present?
      query += "tasks.task_type_id=#{params[:task_type]}"
    end
    if params[:dt_range].present? && params[:dt_range] != "" && !params[:dt_range].blank?
      if params[:dt_range] == "Past Week"
         startdate = 1.week.ago.beginning_of_week.strftime("%Y-%m-%d")
         enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Two Weeks"
         startdate = 2.week.ago.beginning_of_week.strftime("%Y-%m-%d")
         enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Three Weeks"
         startdate = 3.week.ago.beginning_of_week.strftime("%Y-%m-%d")
         enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Month"
         startdate = 1.month.ago.beginning_of_month.strftime("%Y-%m-%d")
         enddate = 1.month.ago.end_of_month.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Year"
         startdate = DateTime.new(Time.zone.now.year-1,1,1).strftime("%Y-%m-%d")
         enddate = DateTime.new(Time.zone.now.year-1,12,31).strftime("%Y-%m-%d")
      end
      query += " and " if query.present?      
      
      query += "`tasks`.`created_at` BETWEEN '#{startdate}' AND '#{enddate}'"
    end
    
    if d_type
     joins(:deal).where(query)
    else
     where(query)
    end
  end
  
  def belongs_to_category
      today_date = Time.zone.now.strftime("%Y/%m/%d")
      due_date = self.due_date.strftime("%Y/%m/%d")
      if  due_date == today_date
        "today"
      #p self.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))  
      elsif due_date < today_date
         "overdue"
      elsif due_date > today_date
         "upcoming"     
      end
  end
  
end

