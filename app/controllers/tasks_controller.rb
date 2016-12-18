class TasksController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  before_filter :retrieve_tasks, :only => [:complete, :start_task, :all_task, :today_task, :overdue_task, :upcoming_task, :calendar_data, :task_filter]
  
 cache_sweeper :cache_sweeper
  
 def index
#    @tasks=Task.task_list(current_user, "all")
    if params[:stask_id].present?
      @task = Task.where("id = ?", params[:stask_id]).first
      if @task.present?
        @task.insert_in_google_calendar
        session.delete(:task_id)
      end
    end
    respond_to do |format|
      format.html
      format.json { render json: TasksDatatable.new(view_context) }
    end
  end

  def create
    taskable=nil
    error_msg=""
  
  respond_to do |format|
#    begin
      if params[:task][:deal_id].present? || params[:taskable_id].present?
        if params[:taskable_type] == "Deal"
          if params[:task][:deal_id].present?
            #@channel="/messages/deals#{params[:task][:deal_id]}"
           p taskable=Deal.find(params[:task][:deal_id])
          else
           p error_msg="Deal doesn't exist."
          end
        elsif params[:taskable_type] == "CompanyContact" || params[:taskable_type] == "IndividualContact"
          if params[:taskable_id].present?
           p taskable=params[:taskable_type].constantize.find(params[:taskable_id])
          else
           p error_msg="Contact doesn't exist."
          end
        end
        if error_msg.blank?
#          if params[:task][:recurring_type] == "none"
#         p task=Task.new(params[:task])
#          task.organization=current_user.organization
#          task.taskable=taskable
#          task.created_by = current_user.id
            if save_task(params, taskable)
             
              # #for pub-sub
              # task= {
                   # created_at: task.created_at.strftime("%I:%M %p"),
                   # created_date: task.created_at.strftime("%y%m%d"),
                   # title: task.get_title,
                   # created_id: task.created_by,
                   # created_by: task.initiator_name == current_user.full_name ? "me" : task.initiator_name,
                   # assigned_id: task.assigned_to,
                   # assigned_name: task.assigned_user_first_name == current_user.full_name ? "me" : task.assigned_user_first_name ,
                   # due_date: task.due_date.strftime("%a %d %b %Y @ %H:%M")
                # }
                
              # PrivatePub.publish_to(@channel, :chat_message => task, :type => "task")
              #end pub-sub
    #          flash[:notice]="Task has been saved successfully."
              session[:task_id] = @task.id                 
              task_info={status: true, msg: "Task has been saved successfully.", ttype: @task.task_type.name, date: @task.due_date.strftime("%a %d %b %Y @ %H:%M"), tdate: task_tab(@task)}
              format.json { render :json => task_info }
            else
                alert_msg=""
                if error_msg ==""
                  msgs=@task.errors.messages
                  msgs.keys.each_with_index do |m,i|
                    alert_msg=m.to_s.camelcase+" "+msgs[m].first
                    alert_msg += "<br />" if i > 0
                  end
                else
                  alert_msg=error_msg
                end
               p alert_msg
               task_info = {status: false, msg: alert_msg.to_s}
		       #redirect_to request.referer 
              format.json { render json: task_info }
    #          format.js {render text: alert_msg.to_s}
            end
          else
            task_info = {status: false, msg: error_msg}
            format.json { render json: task_info }
          end
      else
        if params[:taskable_type] == "Deal" && !params[:task][:deal_id].present?
          error_msg="Selected deal doesn't exist." 
        else
          error_msg="Selected contact doesn't exist."
        end
        p task_info = {status: false, msg: error_msg}
        format.js {render text: task_info}
      end
#    rescue => e
#       p task_info = {status: false, msg: "ERROR 500: Sorry something went wrong!"}
#        format.js {render text: task_info}
#    end
  end
  end
  

  def save_task(params, taskable)
     if(params[:task][:is_event].present? && params[:task][:is_event].to_i == 1)
       all_task_types = current_user.organization.task_types
       meeting_type = all_task_types.where(:name => "Meeting").first
       params[:task][:task_type_id] = meeting_type.id if meeting_type.present?
     end
     puts "_----_____---__----__--__----_---_---__- inside the save task method---------------"
     p params
     @task=Task.new(params[:task])
     @task.organization=current_user.organization
     @task.taskable=taskable
     @task.created_by = current_user.id
     if @task.save
       @task.update_column(:parent_id, @task.id)
       if params[:task][:recurring_type] == "none"
         return true
       else
          start_date=@task.due_date+1.day
          end_date=@task.rec_end_date
          while(start_date <= end_date)
            case @task.recurring_type
            when "daily"
#             if start_date.strftime("%^a") == "FRI"
#               add_date = 3.day
#             elsif start_date.strftime("%^a") == "SAT"
#               add_date = 2.day
#             else
                add_date =1.day
#             end
            when "weekly"
              add_date= 1.week
            when "monthly"
              add_date= 1.month
            when "qtr"
              add_date=3.months
            when "yearly"
              add_date=1.year
            else
              
            end
            new_task=@task.dup
            new_task.due_date=start_date
            new_task.parent_id=@task.id
            new_task.save
            start_date+=add_date
          end
         return true
       end
     else
      return false
     end
  end
  
  def task_tab(task)
      tab_name="all"
      if task.due_date.to_date > Date.today
        tab_name="upcoming"
      elsif task.due_date.to_date == Date.today
        tab_name="today"
      elsif task.due_date.to_date < Date.today
        tab_name="overdue"
      end
      puts "33333333333333333333333333333333333333333333333333333333"
      p tab_name
      tab_name
  end
  
  def follow_up_task
    @follow = Task.find(params[:task_id])
    render partial: "task_follow_form", :content_type => 'text/html'
  end
  
  def edit_task
    @task = Task.find(params[:task_id])
    render partial: "task_form", :content_type => 'text/html'
  end
  
  def update
    task=Task.where("id=?",params[:id]).first
    respond_to do |format|
      if params[:taskable_type].present? && params[:taskable_id].present?
        taskable_obj=params[:taskable_type].constantize.where("id=?", params[:taskable_id]).first
        task.taskable = taskable_obj
        task.deal_id = params[:taskable_id] if params[:taskable_type] == "Deal"
      end
      
      if task.update_attributes(params[:task])
        #flash[:notice]= "Task has been updated successfully."
        #format.json { head :no_content }
        task_info={status: true, msg: "Task has been updated successfully.", ttype: task.task_type.name, date: task.due_date.strftime("%a %d %b %Y @ %H:%M"), tdate: task_tab(task)}
        format.json { render :json => task_info }
      else
          alert_msg=""
          if error_msg ==""
            msgs=task.errors.messages
            msgs.keys.each_with_index do |m,i|
              alert_msg=m.to_s.camelcase+" "+msgs[m].first
              alert_msg += "<br />" if i > 0
            end
          else
            alert_msg=error_msg
          end
         p alert_msg
         task_info = {status: false, msg: alert_msg.to_s}
     #redirect_to request.referer 
        format.json { render json: task_info }
#          format.js {render text: alert_msg.to_s}
      end
    end
  end
  
  def complete
    task = Task.find(params[:task_id])
    @comp_task_type=params[:task_type]
    puts "#######################################"

    #if(params[:create_task] == 1 || params[:create_task] == "1")
     t_note = ""
     tt = ""
     if params[:task_out_val].present?
      params[:task_out_val].chop.split(',').each do |f|
        task_ot_cm = TaskOutcome.find(f)
        t_note += task_ot_cm.name + ","
       if(params[:create_task] == 1 || params[:create_task] == "1")
        if task_ot_cm.task_out_type.present?
         #task_ty_o = task_ot_cm.task_out_type.split(',')
         task_ty = TaskType.where("organization_id = ? and name = ?",@current_organization.id,task_ot_cm.task_out_type).first 
           puts "task complete ======================"
           if(task_ot_cm.task_duration == "1 Day")

             due = Time.now + 1.day
           elsif(task_ot_cm.task_duration == "2 Day")
             due = Time.now + 2.day
           elsif(task_ot_cm.task_duration == "1 Week")
             due = Time.now + 1.week
           elsif(task_ot_cm.task_duration == "2 Week")
             due = Time.now + 2.week
           elsif(task_ot_cm.task_duration == "1 Month")

             due = Time.now + 1.month
           end

		 Task.create(:organization_id=>@current_organization.id,:title=>task_ot_cm.name,:task_type_id=>task_ty.id,:assigned_to=>task.assigned_to,:priority_id=>task.priority_id,:deal_id=>task.deal_id,:due_date=>due,:mail_to=>task.mail_to,:taskable_id=>task.taskable_id,:taskable_type=>task.taskable_type,:created_by=>task.created_by,:task_note=>task_ot_cm.name,:parent_id=>task.parent_id)
        end

      end
    end
   end
    if params[:task_out_val].chop == "8" || params[:task_out_val].chop == 8

     task_note = params[:note]
    elsif params[:task_out_val].present?
    #elsif !t_note.present?
     task_note = t_note.chop
    else
      task_note = task.task_note
    end

    if task.update_attributes(:is_completed => true, :task_note => task_note)
      if(params[:stype]=="task")
        case params[:task_type]
        when "today"
          @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
        when "overdue"
          @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
        when "upcoming"
          @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
        end
        render partial: "task_header", :content_type => 'text/html'
      elsif (params[:stype]=="deal")
        @deal = Deal.find(params[:deal_id])
        @tasks = @deal.tasks
        render partial: "deals/widget_task_header", :content_type => 'text/html'
      elsif (params[:stype]=="dashboard")
        @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(due_date, '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
        render partial: "home/widget_task_header", :content_type => 'text/html'
      elsif (params[:stype]=="contact")
        get_contact_tasks(params[:contact_id])
        @for_contact=true
       render partial: "contacts/task_widget", :content_type => 'text/html'
      end
    else
      flash[:notice]="Plz try again"
    end
  end
  
  def start_task
    task = Task.find(params[:task_id])
    @comp_task_type=params[:task_type]
    if task.update_attributes(:is_completed => false, :task_note => nil)
      if(params[:stype]=="task")
        render partial: "task_header", :content_type => 'text/html'
      elsif (params[:stype]=="contact")
        get_contact_tasks(params[:contact_id])
       render partial: "contacts/task_widget", :content_type => 'text/html'
      elsif (params[:stype]=="deal")
        @deal = Deal.find(params[:deal_id])
        @tasks = @deal.tasks
        render partial: "deals/widget_task_header", :content_type => 'text/html'
      end
    else
      flash[:notice]="Plz try again"
    end
  end
  
  def get_contact_tasks(contact_id)
     @contact=current_user.organization.contacts.where("id=?", contact_id).first
     @today_tasks=Task.task_list(nil,"today",@contact)
     @overdue_tasks=Task.task_list(nil,"overdue",@contact)
     @upcoming_tasks=Task.task_list(nil,"upcoming",@contact)
     @completed_tasks=Task.task_list(nil,"all",@contact).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') <> ? ", true, Time.zone.now.strftime("%Y/%m/%d"))
  end
  
  def task_listing
   unless params[:task_status] == "calendar"
     # @tasks=Task.task_list(current_user, params[:task_type])
     partial_file= "task_list"
   else
     partial_file = "calendar_view"
   end
    render partial: partial_file
  end
  
  def task_filter
    @task_types=params[:ids]
#   @tasks=@tasks.includes(:task_type).where("is_completed=? AND task_types.id IN (?)", false, params[:ids])
	  if params[:cal] 
		render partial: "calendar_view"
		
	  else
		  render partial: "task_list", :content_type => 'text/html'
	  end
  end
  def destroy
    task = Task.find(params[:id])
    deal = task.deal
    if params[:delete_all_task] == "true"
       puts "<<<<<------------------------------"
      tasks=Task.where("parent_id=? And is_completed = false", task.parent_id)
      p tasks
      tasks.destroy_all
    else
      task.destroy
    end  
    t_type = deal.latest_task_type_id.present? ? deal.last_task.name : "No-Action"
    respond_to do |format|
      #flash[:notice]="Task has been deleted successfully."
      format.html { redirect_to request.referer }
      format.json { render json: t_type.to_json, head: :no_content}
      format.js { }
    end
  end
  
  def calendar_data
    if request.xhr?
      events = []
      start_date,end_date="",""
      start_date =Time.zone.at(params[:start].to_i).strftime("%Y/%m/%d") if params[:start].present?
      end_date =Time.zone.at(params[:end].to_i).strftime("%Y/%m/%d") if params[:end].present?
      if (params[:deal_type] != "" ||  params[:asg_to] != "" || params[:task_type] != "")
        @tasks = @tasks.active_multi_filter(params)
      end
      #@tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') BETWEEN ? AND ?", false, start_date, end_date )
      if params[:filter_type].present? && params[:filter_type] == "all"
         @tasks=@tasks.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') BETWEEN ? AND ?",  start_date, end_date )
      else
          @tasks=@tasks.where("is_completed=? and DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') BETWEEN ? AND ? and (DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') = ? or DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?)",  false, start_date, end_date, Time.zone.now.strftime("%Y/%m/%d"),Time.zone.now.strftime("%Y/%m/%d") )
      end
	  @tasks.each do |task|
        deal = task.taskable
		if task && deal
      task.due_date= task.created_at unless task.due_date.present?
			if  task.user && task.user.image && task.user.image.present?
			 imgurl = task.user.image.image(:icon)
			else
			 imgurl = "/assets/no_user.png"
			end
			events << {:id => task.id, :img=>imgurl, :is_complete=> task.is_completed, :tasktype=> task.task_type.name , :assign_to=> "#{(task.user.present? ? task.user.full_name : 'NA')}", :url=> "http://#{request.host_with_port}/leads/#{deal.id}", :title => "\n"+task.title+ "\n" + "Deal:" +" "+deal.title+ "\n" ,   :color=> TaskType::TASK_COLORS[task.task_type.name], :className=>"test", :description => "At - #{task.due_date.strftime('%H:%M')}\nTask - "+task.title+"\n Deal - " + deal.title+"\nAssigned To - "+(task.user ? task.user.full_name : ""), :start => "#{task.due_date.iso8601}", :end => "#{task.due_date.iso8601}", :allDay => false}
	    end
      end
    end
    respond_to do |format|
      format.json { render json: events}
    end
  end
  
  
  def get_sqllite_task
  tasks = []
  @tasks = Task.todays_task(current_user)
	@tasks.each do |tsk|
	tasks <<
	{
	  title: tsk.get_title ,
	  duedate: tsk.due_date,
	  created_by: tsk.initiator_name,
	  assigned_to: tsk.assigned_user_first_name,
	  deal_id: tsk.deal_id,
	  tasktype: tsk.task_type.name,
	  is_complete: 0,
	  is_notified: 0
	}
	end
	respond_to do |format|
      format.json { render json: tasks}
    end
  end
  
  def task_tab_data
    render partial: "task_tab_data"
  end
  
private
  def retrieve_tasks
    query_condition=[]
    if @current_user.is_admin? || @current_user.is_super_admin?
      #query_condition.where("organization_id=?", @current_organization.id)
	  query_condition.where("tasks.organization_id=?", @current_organization.id)

    else
      #query_condition.where("organization_id=? AND (tasks.assigned_to=? OR tasks.created_by=?)", @current_organization.id, @current_user.id, @current_user.id)
	  query_condition.where("tasks.organization_id=? AND (tasks.assigned_to=? OR tasks.created_by=?)", @current_organization.id, @current_user.id, @current_user.id)

    end
    @tasks=Task.includes(:task_type, :user, :taskable).where(query_condition).order("due_date DESC,priority_id")
  end
end
