class HomeController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  require 'net/http'
  include HomeHelper
  include TasksHelper
  include ApplicationHelper #FIXME AMT
  include DealsHelper
  include HotLeadAssignment
   
   
  skip_before_filter  :authenticate_user!, :only => [:index, :pricing, :notfound, :terms, :privacy, :security,:contact_us, :clear_cache,:api_contact_us, :download_user, :report_a_bug, :show_bug_report, :post_comment]
  
  caches_action :terms,:privacy#, :security
  
  
  def index   
   if !params[:t].nil? || !params[:t].blank?
     if BetaAccount.exists?(:invitation_token => params[:t])
        buser = BetaAccount.find_by_invitation_token params[:t]
        @buser_email = buser.email if buser.email
     end
   end  
  end
  
  
  def dashboard
    if @current_user.is_siteadmin?
      @busers = BetaAccount.order("updated_at desc")
    end
  end
  
  def summary
    last_deal_condition=[]
    if (@current_user.is_admin? || @current_user.is_super_admin?)
      last_deal_condition.where("deals.organization_id =? AND deal_statuses.original_id IN (?) AND deals.is_active=?", @current_user.organization_id, [4], true)
    else
      last_deal_condition.where(" deals.organization_id =? AND deal_statuses.original_id IN (?) AND deals.is_active=? AND (deals.assigned_to=? or initiated_by=?)", @current_user.organization_id, [4], true, @current_user.id, @current_user.id)
    end
    @last_deal=Deal.last_three_months.includes(:deal_status).select("deals.id, deals.created_at, deals.updated_at, deals.assigned_to, deals.deal_status_id").where(last_deal_condition).order("deals.updated_at desc").first
    if @last_deal.present?
       @last_closed_deal = @last_deal.present? ?  @last_deal : "Yet to close a deal."       
       @last_closed_user = @last_deal.present? ?  @last_deal.closed_by_name : ""       
       
      close_deal_date = DealMove.by_deal_id_and_status_won(@last_deal.id, @last_deal.deal_status_id).first.created_at.in_time_zone(@current_user.time_zone)
       @last_close_deal_date = close_deal_date.strftime("%Y").to_s == Time.zone.now.year.to_s ? close_deal_date.strftime("%b %d") : close_deal_date.strftime("%b %d, %Y")
       @ratio = Deal.avg_time_close_deal @current_user, @current_organization.id, 3.months.ago , Time.zone.now.tomorrow      
    end
    render partial: "summary"
  end
  
  def task_widget_page
    render partial: "home/widget_task_header"
  end
  
  def deal_statistics_info
    ##Deal statistics non-admin user
    @current_quarter =  quarter_month_numbers Date.today

    unless @current_user.is_super_admin? || @current_user.is_admin?
     current_quarter = get_current_quarter Date.today
     current_year = Time.zone.now.year
     case current_quarter
      when 1
        @start_date = DateTime.new(Time.zone.now.year,1,1)
        @end_date = DateTime.new(Time.zone.now.year,3,31)     
      when 2
        @start_date = DateTime.new(Time.zone.now.year,4,1)
        @end_date = DateTime.new(Time.zone.now.year,6,30)     
      when 3
        @start_date = DateTime.new(Time.zone.now.year,7,1)
        @end_date = DateTime.new(Time.zone.now.year,9,30)
      when 4
        @start_date = DateTime.new(Time.zone.now.year,10,1)
        @end_date = DateTime.new(Time.zone.now.year,12,31)     
      end
      @pportunity = Opportunity.find(:all, :conditions => ['user_id = ? AND year = ? AND quarter = ?',current_user.id,  current_year, current_quarter ])
      if @pportunity.present?
        if current_user.admin_type == 3 && current_user.role.present?
          @total_users = User.where("organization_id=? AND role_id=?", current_user.organization.id, current_user.role.id).count
          @above_rate_users = Opportunity.where("organization_id= ? AND user_id != ? AND year=? AND quarter = ? AND win > ?", current_user.organization.id, current_user.id,current_year, current_quarter, @pportunity.first.win ).count            
          @ratio = calculate_deals_rate @above_rate_users, @total_users
        end
      end
      @salescycle = SalesCycle.find(:all, :conditions => ['user_id = ? AND year = ? AND quarter = ?',current_user.id,  current_year, current_quarter ])
      if @salescycle.present?
        total_deals_quarter = SalesCycle.count(:all,:conditions=>['organization_id = ? and year = ? and quarter = ?',current_user.organization.id, current_year, current_quarter])
        sum = SalesCycle.sum(:average, :conditions => ['organization_id = ? and year = ? and quarter = ?', current_user.organization.id, current_year, current_quarter])
        @avg_days_for_all_deal = calcalute_avg_deal_org sum, total_deals_quarter
        if current_user.admin_type == 3 && current_user.role.present?
          @above_rate_users_sales_cycle = SalesCycle.where("organization_id= ? AND user_id != ? AND year=? AND quarter = ? AND average < ?", current_user.organization.id, current_user.id,current_year, current_quarter, @salescycle.first.average ).count     
          @ratio_salescycle = calculate_deals_rate @above_rate_users_sales_cycle, @total_users
          
        end
      end
    end
    render partial: "statistics_quarterly"
  end
  
  def line_chart_display
    begin
      if @current_organization.deals.first.present? 
        last_week_day = Time.zone.now
        weeks=[]
        months=[]
        new_deals=[]
        qualified_deals=[]
        won_deals=[]
        lost_deals=[]
        new_deals_count=[]
        close_deals_count=[]
        avg_close_deals_count=[]
        ## Calculating data for the deal statistics weekly basis
        4.times do
          weeks << last_week_day.strftime("%b %d")
          current_week_day= last_week_day - 1.week
          all_deals_weekly=get_deals_for_range(current_week_day, last_week_day)
          total_counts=Deal.includes(:deal_status).select("deals.id, deals.created_at").where("deals.deal_status_id IS NOT NULL").where(all_deals_weekly).group("deal_statuses.original_id").count
          new_count = total_counts.values.sum
          # Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_weekly).order("deals.created_at DESC").count
          close_count =total_counts.values_at(4).first
          close_count=0 if close_count.nil?
          # Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_weekly).order("deals.created_at DESC").where("deal_statuses.original_id IN (?) ", [4]).count
          new_deals_count << new_count
          close_deals_count << close_count
          avg_close_deals_count << ((new_count != 0 && close_count != 0) ?  (new_count.to_i/close_count.to_i)/100 : 0)
          last_week_day = current_week_day
        end
        @deal_line_chart = LazyHighCharts::HighChart.new('graph') do |f|
           f.xAxis({categories: weeks.reverse,title: {text: "weeks"}})
           f.series(:name=> "New deals",:data=> new_deals_count.reverse)
           f.series(:name=> "Closed deals",:data=> close_deals_count.reverse)
           f.series(:name=> "Closed deal ratio",:data=> avg_close_deals_count.reverse)
           f.yAxis( title: { text: "Deals",align: 'high'}, labels: { overflow: 'justify'})
           f.legend({verticalAlign: 'bottom',
                    backgroundColor: 'white',
                    borderColor: '#CCC',
                    borderWidth: 1,
                    shadow: false
                })
           f.title({ :text=>" "})
           # Options for Bar
           f.options[:chart][:defaultSeriesType] = "line"
        end
      end
    # rescue
      # @deal_line_chart = LazyHighCharts::HighChart.new('graph')
    ensure
      @deal_line_chart = LazyHighCharts::HighChart.new('graph')
      render partial: 'line_chart_display'
    end
  end
  
  def pie_chart_display
    begin
      if @current_organization.deals.first.present?
        last_week_day = Time.zone.now
        weeks=[]
        months=[]
        new_deals=[]
        qualified_deals=[]
        won_deals=[]
        lost_deals=[]
        new_deals_count=[]
        close_deals_count=[]
        avg_close_deals_count=[]

        month_start_date=Time.zone.now.change(day: 1)
        month_end_date=month_start_date.end_of_month
        ## Calculating data for the deal statistics monthly basis





        3.times do
          all_deals_monthly=get_deals_for_range(month_start_date, month_end_date)
          deal_counts=Deal.includes(:deal_status).select("deals.id, deals.created_at").where("deals.deal_status_id IS NOT NULL").where(all_deals_monthly).group("deal_statuses.original_id").count
          months << month_start_date.strftime("%b")
          nd=deal_counts.values.sum
          new_deals << (nd.nil? ? 0 : nd)
  #                Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_monthly).count
          qd=deal_counts.values_at(2).first
          qualified_deals << (qd.nil? ? 0 : qd)
  #                Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_monthly).where("deal_statuses.original_id IN (?) ", [2]).order("deals.created_at DESC").count
          wd=deal_counts.values_at(4).first
          won_deals <<  (wd.nil? ? 0 : wd)
  #                Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_monthly).where("deal_statuses.original_id IN (?) ", [4]).order("deals.created_at DESC").count
          ld=deal_counts.values_at(5).first
          lost_deals << (ld.nil? ? 0 : ld)
  #                Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_monthly).where("deal_statuses.original_id IN (?) ", [5]).order("deals.created_at DESC").count
          month_end_date = month_start_date - 1.day
          month_start_date = month_end_date.change(day: 1)
        end
        if @current_user.is_admin?
          @deal_bar_chart  = LazyHighCharts::HighChart.new('column') do |f|
            f.xAxis({categories: months.reverse,title: {text: "months"}})
            f.series(:name=>'New',:data=> new_deals.reverse)
			f.series(:name=>'Qualified',:data=> qualified_deals.reverse)
			f.series(:name=>'Won',:data=> won_deals.reverse ) 
			f.series(:name=>'Lost',:data=> lost_deals.reverse) 
            f.colors([ '#3497DB', '#F39C11','#2DCC70', '#E74B3C' ])
             f.title({ :text=>""})
             f.legend({verticalAlign: 'bottom',
                      backgroundColor: 'white',
                      borderColor: '#CCC',
                      borderWidth: 1,
                      shadow: false
                  })
            f.options[:chart][:defaultSeriesType] = "column"
            f.plot_options({:column=>{:stacking=>"normal"}})
           end
        end
       else
        @deal_bar_chart  = LazyHighCharts::HighChart.new('column')
      end
    rescue
      @deal_bar_chart  = LazyHighCharts::HighChart.new('column')
    ensure
     render partial: "pie_chart_display"
    end
  end
  
  def pie_donut_chart
    begin
      new_deal_piedonut=Deal.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").where(deal_status_count_last_one_month).group("deal_statuses.original_id").count
      q_piedonut=new_deal_piedonut.values_at(2).first
      l_piedonut=new_deal_piedonut.values_at(5).first
      w_piedonut=new_deal_piedonut.values_at(4).first
        @piedonut_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart({ type: 'pie', height:282})
        #f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
        f.colors([ '#3497DB', '#F39C11','#2DCC70', '#E74B3C' ]) 
		f.title({ text: ''})
        f.plotOptions({ 
          pie: { shadow: false}
        })
        f.series({
          name: 'Total:',
          data: [
                ['New',    new_deal_piedonut.values.sum],
                ['Qualified',     (q_piedonut.nil? ? 0 : q_piedonut)],
				['Won',     (w_piedonut.nil? ? 0 : w_piedonut)],
                ['Lost',    (l_piedonut.nil? ? 0 : l_piedonut)]
              ],
          size: '60%',
          innerSize: '20%',
          showInLegend:true,
          innerSize: '20%',
          showInLegend: true
         })
          f.legend({verticalAlign: 'bottom',
                      backgroundColor: 'white',
                      borderColor: '#CCC',
                      borderWidth: 1,
                      shadow: false
                  })
        end
    rescue
      @piedonut_chart = LazyHighCharts::HighChart.new('column')
    ensure
      render partial: "pie_donut_chart"
    end
  end
  
  def load_header_count_section
    count_condition=get_deal_status_count([1,2,3,4,5,6])
    @new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=?", [1], false).count

    @working_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) AND is_current=? and is_remote=? ", [1,2,3,4,5,6], true, false).count

    @qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=?", [2], false).count

    if badge_today.to_i > 0
      @task_count = badge_today
      @task_text="Today's tasks"
      @task_url = "/tasks?type=today"
    elsif badge_overdue.to_i > 0
      @task_count = badge_overdue
      @task_text="Overdue tasks"
      @task_url = "/tasks?type=overdue"
    elsif badge_upcoming.to_i > 0
      @task_count = badge_upcoming
      @task_text="Upcoming tasks"
      @task_url = "/tasks?type=upcoming"
    else
      @task_count = badge_all
      @task_text="Tasks"
      @task_url = "/tasks"
    end
    render partial: "load_header_count_section", :content_type => 'text/html'
  end
  
  
  def contact_us
   if request.post?
    build_contact_us_info(params[:email],params[:name],params[:comment])
    Notification.contact_us_mail(params[:email],params[:name],params[:comment]).deliver    
    flash[:notice] = "Your mail has been send successfully.We will contact you soon."   
   end
  end
  
  def task_widget
    unless @current_user.is_super_admin? || @current_user.is_admin?
        @tasks=Task.includes(:deal).includes(:user).task_list(@current_user, params[:task_type], nil, 10) if @current_user.present?
        @task_type=params[:task_type] if params[:task_type].present?
        render partial: "widget_task_list", :content_type => 'text/html'
    else        
        admint = Task.where("(assigned_to=? )", @current_user.id) .includes(:deal).includes(:user).task_list_dashboard(@current_user, params[:task_type], nil, 10).order("assigned_to").group_by{|d| d.assigned_to} if @current_user.present?
        if admint.values.map(&:size)[0].to_i < 10        
             @non_admin_tasks=Task.where("(assigned_to != ? OR created_by != ?)", @current_user.id, @current_user.id) .includes(:deal).includes(:user).task_list(@current_user, params[:task_type], nil, 10-admint.values.map(&:size)[0].to_i).order("assigned_to").group_by{|d| d.assigned_to} if @current_user.present?
             @tasks =  admint.merge!(@non_admin_tasks)
        else
             @tasks = admint
        end
        @task_type=params[:task_type] if params[:task_type].present?
        render partial: "admin_widget_task_list", :content_type => 'text/html'
    end
    
    
  end
  
 def activities
    @activities = activity_stream(@current_user.organization.id).first(2)
    #puts "##################33"
    #p @activities.first.class.name
    #render :json => @activities
    respond_to do |format|
      format.html
      #format.json { render json: get_activities_json(activities) }
    end
  end
  
  def get_activities
    if(params[:pagesource]=="dashboard")
      per_page = 10
    else
      per_page = 20
    end
    activities = activity_stream(@current_user.organization.id,(params[:page]).to_i,per_page)
    render :json=>get_new_activities_json(activities)
  end
  
  def get_new_activities_json(activities)
    acts = []
    activities.each do |activity|
      id =0
      title=""
      created_by=""
      assigned_to =""
      due_date= nil
      created_at=nil
      attachment=nil
      is_complete = false 
      move_status =""
      created_by_id = 0
      note_att = 0
      url = ""
      actual_date = ""
      task_user_url = ""      
      activity_txt = ""
      activity_status_type = ""
      publish_status = false
      
      if(activity.activity_type == "Task")        
        if activity.activity_status == "Archive"
          activity_txt = "Archived Task"
          created_at=activity.activity_date
          title=activity.activity_desc
          created_by=activity.user.present? ? activity.user.first_name : ""
          created_by_id = activity.user.present? ? activity.user.id : ""
          actual_date = activity.activity_date.strftime("%I:%M %p")
          activity_status_type = activity.activity_status
        else
            task = Task.where(:id=> activity.activity_id).first        
            if task.present?
            id=activity.activity_id
            title=activity.activity_desc
            if activity.activity_status == "Create" || activity.activity_status == "Update" || activity.activity_status == "Complete"
               created_by=activity.user.present? ? activity.user.first_name : ""
               created_by_id = activity.user.present? ? activity.user.id : ""
               assigned_to=""
               task_user_url= ""
               activity_txt = activity.activity_status == "Create" ? "Created Task" : (task.is_completed == true ? "Completed Task" : "Updated Task")
            else
               created_by= task.initiator.present? ? task.initiator.first_name : ""
               created_by_id = task.initiator.present? ? task.initiator.id : ""
               assigned_to= activity.user.present? ? activity.user.first_name : ""           
               task_user_url= activity.user.present? ? "/profile/#{activity.user.id}" : ""
               activity_txt = "Created and Assigned Task"
            end        
            due_date = task.due_date.present? ? task.due_date.strftime("%a %d %b %Y @ %H:%M") : ""
            created_at=activity.activity_date
            is_complete = task.is_completed
            url=task.get_url        
            actual_date = activity.activity_date.strftime("%I:%M %p")
            active = task.taskable.is_active
            activity_status_type = activity.activity_status
           end
         end
         
         if task.present? && task.taskable.present? 
             if task.taskable.class.name == "Deal"
               publish_status = task.taskable.is_public == false ? ((task.taskable.associated_users.include? @current_user.id) || ( @current_user.is_admin? ||  @current_user.is_super_admin?) || (task.user.id == @current_user.id) ? true : false) : true
             else
               publish_status = task.taskable.is_public == false ? ((@current_user.is_admin? || @current_user.is_super_admin?) || (@current_user.id == task.taskable.created_by) || (task.user.id == @current_user.id) ? true : false) : true
             end
         end
         
         
      end
      
      if(activity.activity_type == "Deal")
        deal = Deal.find activity.activity_id
        id=activity.activity_id
        title=activity.activity_desc        
        if activity.activity_status == "Create" || activity.activity_status == "Update" || activity.activity_status == "Archive"
          created_by=activity.user.first_name if activity.user.present?
          created_by_id = activity.user.present? ? activity.user.id : ""
          activity_txt = activity.activity_status == "Create" ? "Created Deal" : (deal.is_active == false ? "Archived Deal" : "Updated Deal")
          assigned_to= ""
        else
          assigned_to=activity.user.first_name if activity.user.present?
          created_by_id = activity.user.id if activity.user.present?
          created_by = deal.initiator.first_name if deal.initiator.present?
          activity_txt = "Created Deal and Assigned"
        end        
        created_at=activity.activity_date
        url = lead_path(deal)
        actual_date = activity.activity_date.strftime("%I:%M %p")
        active = deal.is_active
        activity_status_type = activity.activity_status
        if deal.is_public == false
           publish_status = ((deal.associated_users.include? @current_user.id) || ( @current_user.is_admin? ||  @current_user.is_super_admin?) ? true : false)
        else
           publish_status = true
        end
      end
      
      
      if(activity.activity_type == "DealMove")
        dealmove = DealMove.find activity.activity_id
        id=activity.activity_id
        title=activity.activity_desc  
        created_by=activity.user.first_name if activity.user.present?
        created_at=activity.activity_date
        move_status=dealmove.deal_status.name
        created_by_id = activity.user.id if activity.user.present?
        url=lead_path(dealmove.deal)
        actual_date = activity.activity_date.strftime("%I:%M %p")
        active = dealmove.deal.is_active
        activity_status_type = activity.activity_status
        activity_txt = ""
        if dealmove.deal.is_public == false
           publish_status = ((dealmove.deal.associated_users.include? @current_user.id) || ( @current_user.is_admin? ||  @current_user.is_super_admin?) ? true : false)
        else
           publish_status = true
        end
      end
      
      if(activity.activity_type == "IndividualContact")
        contact = IndividualContact.find activity.activity_id
        id=activity.activity_id
        #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
        title=activity.activity_desc        
        created_by= activity.user.first_name if activity.user.present?
        created_at=activity.activity_date
        created_by_id = activity.user.id if activity.user.present?
        url="/individual_contact/#{contact.id}"
        actual_date = activity.activity_date.strftime("%I:%M %p")
        activity_status_type = activity.activity_status
        active = contact.is_active
        activity_txt = activity.activity_status == "Create" ? "Created Contact" : (activity.activity_status == "Archive" ? "Archived Contact" : "Updated Contact")
        publish_status = ((@current_user.is_admin? || @current_user.is_super_admin?) || (@current_user.id == contact.created_by) ? true : false)
      end
      
      if(activity.activity_type == "CompanyContact")
        contact = CompanyContact.find activity.activity_id
        id=activity.activity_id
        #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
        title = activity.activity_desc        
        created_by= activity.user.first_name if activity.user.present?
        created_at=activity.activity_date
        created_by_id = activity.user.id if activity.user.present?
        url="/company_contact/#{contact.id}"
        actual_date = activity.activity_date.strftime("%I:%M %p")
        activity_status_type = activity.activity_status
        active = contact.is_active
        activity_txt = activity.activity_status == "Create" ? "Created Contact" : (activity.activity_status == "Archive" ? "Archived Contact" : "Updated Contact")
        if contact.is_public == false
            publish_status = ((@current_user.is_admin? || @current_user.is_super_admin?) || (@current_user.id == contact.created_by) ? true : false)
        else
            publish_status = true
        end
      end
      
      if(activity.activity_type == "Note")
        note = Note.find activity.activity_id
        note_a = NoteAttachment.find_by_note_id note.id 
        id=activity.activity_id
        title = activity.activity_desc        
        created_by=activity.user.first_name if activity.user.present?
        created_at=activity.activity_date
        #attachment= note.attachment.present? ? note.attachment.url : "null"
        attachment= note.attachment_urls.present? ? note.attachment_urls : "null"
        created_by_id = activity.user.id if activity.user.present?
        url=""
        actual_date = activity.activity_date.strftime("%I:%M %p")
        activity_status_type = activity.activity_status
        activity_txt = ""
        publish_status = true
      end
      if(activity.activity_type == "MailLetter")
        mail_letter = MailLetter.find activity.activity_id
        
        id=activity.activity_id
        if(!mail_letter.contact_info.nil?)
          url="/#{mail_letter.contact_info['contact_type'].to_s}/#{mail_letter.contact_info['contact_id'].to_s}"
        else
          url=""
        end
        if(!mail_letter.contact_info.nil?)
          contact_info =mail_letter.contact_info
          title = "Mail Sent to <a src='#{url}'>#{contact_info['full_name']}</a>"     
        else
          title ="Mail Sent to  " + mail_letter.mailto  
        end 
        created_by=activity.user.first_name if activity.user.present?
        created_at=activity.activity_date
        created_by_id = activity.user.id if activity.user.present?
        actual_date = activity.activity_date.strftime("%I:%M %p")
        activity_status_type = activity.activity_status
        activity_txt = mail_letter.subject
        publish_status = true
      end
      if(created_by_id == @current_user.id)
        created_by = "me"
      end  
      #if publish_status == true
        acts << {
          type: activity.activity_type,
          id: id,
          title: title,
          created_by: created_by,
          assigned_to: assigned_to,
          due_date: due_date,
          created_at: created_at,
          attachment: attachment,
          is_complete: is_complete,
          move_status: move_status,
          created_at_int: created_at.to_i,
          url: url,
          actual_date: actual_date,
          created_by_id: created_by_id,
          active: active,
          task_pro_url: task_user_url,
          activity_status_type: activity_status_type,
          activity_txt: activity_txt
        }
      #end
    end
    return acts
  end
  
  
  
  
  
  def get_activities_json(activities)
    # activities << org.deals
     # activities << org.deal_moves
     # activities << org.contacts
     # activities << org.tasks
     # activities << org.attachments
    acts = []
    activities.each do |activity|
      id =0
      title=""
      created_by=""
      assigned_to =""
      due_date= nil
      created_at=nil
      attachment=nil
      is_complete = false 
      move_status =""
      created_by_id = 0
      url = ""
      actual_date = ""
      task_user_url = ""
      if(activity.name == "Organization")
        org = Organization.find activity.id
        id=org.id
        title=org.name
        #created_by=org.user.full_name
        created_at=org.created_at
        attachment= ""
        #created_by_id = org.id
        url=""
      end
      if(activity.name == "Task")
        task = Task.find activity.id
        id=task.id
        title=task.get_title
        created_by=task.initiator.present? ? task.initiator.first_name : ""
        assigned_to=task.user.present? ? task.user.full_name : ""
        due_date = task.due_date.present? ? task.due_date.strftime("%a %d %b %Y @ %H:%M") : ""
        created_at=task.created_at
        is_complete = task.is_completed
        created_by_id = task.initiator.present? ? task.initiator.id : ""
        url=task.get_url
        task_user_url="/profile/#{task.assigned_to}"
        actual_date = task.created_at.strftime("%I:%M %p")
        active = task.taskable.is_active
      end
      if(activity.name == "Deal")
        deal = Deal.find activity.id
        id=deal.id
        title=deal.title
        created_by=deal.initiator.first_name if deal.initiator.present?
        assigned_to=deal.assigned_user.full_name if deal.assigned_user.present?
        created_at=deal.created_at
        created_by_id = deal.initiator.id if deal.initiator.present?
        url=lead_path(deal)
        actual_date = deal.created_at.strftime("%I:%M %p")
        active = deal.is_active
      end
      if(activity.name == "DealMove")
        dealmove = DealMove.find activity.id
        id=dealmove.id
        title=dealmove.deal.title
        created_by=dealmove.user.first_name if dealmove.user.present?
        created_at=dealmove.created_at
        move_status=dealmove.deal_status.name
        created_by_id = dealmove.user.id if dealmove.user.present?
        url=lead_path(dealmove.deal)
        actual_date = dealmove.created_at.strftime("%I:%M %p")
        active = dealmove.deal.is_active
      end
      if(activity.name == "IndividualContact")
        contact = IndividualContact.find activity.id
        id=contact.id
        #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
        title = contact.full_name
        created_by= contact.initiator.present? ? contact.initiator.first_name : ""
        created_at=contact.created_at
        created_by_id = contact.initiator.present? ? contact.initiator.id : ""
        url="/individual_contact/#{contact.id}"
        actual_date = contact.created_at.strftime("%I:%M %p")
      end
      if(activity.name == "CompanyContact")
        contact = CompanyContact.find activity.id
        id=contact.id
        #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
        title = contact.full_name
        created_by= contact.initiator.present? ? contact.initiator.first_name : ""
        created_at=contact.created_at
        created_by_id = contact.initiator.present? ? contact.initiator.id : ""
        url="/company_contact/#{contact.id}"
        actual_date = contact.created_at.strftime("%I:%M %p")
      end
      #if(activity.name == "Contact")
      #  contact = Contact.find activity.id
      #  id=contact.id
      #  title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
      #  created_by=contact.initiator.full_name
      #  created_at=contact.created_at
      #  created_by_id = contact.initiator.id
      #  url=contact_path(contact)
      #  actual_date = contact.created_at.strftime("%I:%M %p")
      #end
      if(activity.name == "Note")
        note = Note.find activity.id
        id=note.id
        title=note.notes
        created_by=note.user.first_name if note.user.present?
        created_at=note.created_at
        attachment= note.note_attachments.attachment.present? ? note.note_attachments.attachment.url : "null"
        created_by_id = note.user.id if note.user.present?
        url=""
        actual_date = note.created_at.strftime("%I:%M %p")
      end
      if(created_by_id == @current_user.id)
        created_by = "me"
      end  
      acts << {
        type: activity.name,
        id: id,
        title: title,
        created_by: created_by,
        assigned_to: assigned_to,
        due_date: due_date,
        created_at: created_at,
        attachment: attachment,
        is_complete: is_complete,
        move_status: move_status,
        created_at_int: created_at.to_i,
        url: url,
        actual_date: actual_date,
        created_by_id: created_by_id,
        active: active,
        task_pro_url: task_user_url
      }
    end
    return acts
  end
  
  def get_deals_for_range(deal_status=[1,2,3,4,5,6], month_start_date, last_week_day)
    deals_range_condition=[]
    if @current_user.is_admin? || @current_user.is_super_admin?
      deals_range_condition.where("deals.organization_id=?", @current_user.organization_id)
#      total_deals=Deal.where("deals.organization_id=?", @current_user.organization_id)
    else
      deals_range_condition.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?", @current_user.id, @current_user.id, @current_user.organization.id)
#      total_deals =@current_user.my_deals
    end
      deals_range_condition.where("(DATE_FORMAT(DATE_ADD(deals.created_at, INTERVAL #{Time.zone.now.utc_offset} second), '%Y-%m-%d') between (?) AND (?))", month_start_date.strftime("%Y-%m-%d"), last_week_day.strftime("%Y-%m-%d"))
      deals_range_condition.where("(deals.assigned_to=?)", @current_user.id) unless (@current_user.is_admin? || @current_user.is_super_admin?)
#    deals=total_deals.includes(:deal_status).select("deals.id, deals.created_at").where("deal_statuses.original_id IN(?) AND (DATE_FORMAT(DATE_ADD(deals.created_at, INTERVAL #{Time.zone.now.utc_offset} second), '%Y-%m-%d') between (?) AND (?))", deal_status, month_start_date.strftime("%Y-%m-%d"), last_week_day.strftime("%Y-%m-%d"))
#    deals=deals.where("(deals.assigned_to=?)", @current_user.id) unless (@current_user.is_admin? || @current_user.is_super_admin?)
    deals_range_condition
  end
  
  
  def get_users_activity_count(start_date, end_date)
      activities=Task.find_by_sql("select count(*) count , created_by from ((select id,'Deal' as name,created_at,initiated_by created_by from deals where organization_id =  #{@current_user.organization.id} AND initiated_by != #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'CompanyContact' as name,created_at,created_by from company_contacts where organization_id =  #{@current_user.organization.id} AND created_by != #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'IndividualContact' as name,created_at,created_by from individual_contacts where organization_id =  #{@current_user.organization.id} AND created_by != #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'DealMove' as name,created_at,created_by from notes where notable_type = 'DealMove' and organization_id =  #{@current_user.organization.id} AND created_by != #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'Task' as name,created_at,created_by from tasks where organization_id =  #{@current_user.organization.id} AND created_by != #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'Task' as name,updated_at as created_at,assigned_to created_by from tasks where is_completed=1 and organization_id =  #{@current_user.organization.id}  AND assigned_to != #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'Note' as name,created_at,created_by from notes where organization_id =  #{@current_user.organization.id} AND created_by != #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
	UNION ALL
    (select id,'Mail' as name,created_at,mail_by created_by  from mail_letters where organization_id =  #{@current_user.organization.id}  AND mail_by != #{@current_user.id}  AND created_at BETWEEN '#{start_date}' AND '#{end_date}')) activities
    group by created_by order by count(*) desc limit 4")
    activities
  end
  
  def get_current_user_activity_count(start_date, end_date)
      activities=Task.find_by_sql("select count(*) count , created_by from (select id,'Deal' as name,created_at,initiated_by created_by from deals where organization_id = #{@current_user.organization.id}  AND initiated_by = #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}'
    UNION ALL
    (select id,'CompanyContact' as name,created_at,created_by from company_contacts where organization_id = #{@current_user.organization.id} AND created_by = #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'IndividualContact' as name,created_at,created_by from individual_contacts where organization_id = #{@current_user.organization.id} AND created_by = #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'DealMove' as name,created_at,created_by from notes where notable_type = 'DealMove' and organization_id =  #{@current_user.organization.id} AND created_by = #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'Task' as name,created_at,created_by from tasks where organization_id = #{@current_user.organization.id} AND created_by = #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'Task' as name,updated_at as created_at,assigned_to created_by from tasks where is_completed=1 and organization_id =  #{@current_user.organization.id}  AND assigned_to = #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
    UNION ALL
    (select id,'Note' as name,created_at,created_by from notes where organization_id =  #{@current_user.organization.id} AND created_by = #{@current_user.id} AND created_at BETWEEN '#{start_date}' AND '#{end_date}')
	UNION ALL
    (select id,'Mail' as name,created_at,mail_by created_by  from mail_letters where organization_id =  #{@current_user.organization.id} AND mail_by = #{@current_user.id}  AND created_at BETWEEN '#{start_date}' AND '#{end_date}')) activities

group by created_by order by count(*) desc")
    activities
  
  end
  
 def usage
  usage = []
  unless (@current_user.is_admin? || @current_user.is_super_admin?)
     if @current_organization.won_deal_status().present?
	 owndeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.won_deal_status().id,:assigned_to=>@current_user.id).count
	 end
	 if @current_organization.lost_deal_status().present?
      lostdeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.lost_deal_status().id,:assigned_to=>@current_user.id).count
	 end 
     total_deals = @current_user.all_assigned_or_created_deals.where(:is_active=>true).count     
     call_cmpl = Task.joins(:task_type).where("task_types.name='Call' and task_types.organization_id=? and tasks.organization_id=? and tasks.is_completed=1 and tasks.assigned_to=? ",@current_organization.id,@current_organization.id,@current_user.id).count
     leadsnortured = @current_organization.deals.includes(:deal_status).where(:is_active=>true,:assigned_to=>@current_user.id).where("deal_statuses.original_id IN (?) ", [2,3,4,5,6]).count
  else
      owndeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.won_deal_status().id).count
      lostdeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.lost_deal_status().id).count
     total_deals = @current_organization.deals.where(:is_active=>true).count
     call_cmpl = Task.joins(:task_type).where("task_types.name='Call' and task_types.organization_id=? and tasks.organization_id=? and tasks.is_completed=1  ",@current_organization.id,@current_organization.id).count
     leadsnortured = @current_organization.deals.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", [2,3,4,5,6]).count   
  end 
  lostdeal = lostdeal.nil? ? 0 : lostdeal
  owndeal = owndeal.nil? ? 0 : owndeal
  task_cmpl = badge_completed
  
     usage = {
	 owndeal: owndeal,
	 lostdeal: lostdeal,
	 deals: total_deals,
	 task_cmpl: task_cmpl,
	 call_cmpl: call_cmpl,
	 leadsnortured: leadsnortured
	 }
	 render json: usage
  end
  
  def notfound
  end
  
  def fetch_notification_count
    @tnc= params[:tnc]
    render partial: "shared/notification_counts"
  end
  def getting_started
  
  end

  def clear_cache
      puts "---------------fragments"
      
     # fragment = "*#{fragment.to_s.split(':').last.gsub(')', '')}*"
      
      
     # p fragment_exist?("cache:views/user_menu_207/dcf3768d7d134837f070386fce46ce9d")
    #  p fragment_exist?("views/user_menu_#{@current_user.id}/*")
    #  p Rails.cache.get("cache:views/user_menu_207/dcf3768d7d134837f070386fce46ce9d")
      #expire_fragment("user_menu_#{@current_user.id}") if @current_user.present?
     # cache.increment "counter"
     # p cache.read "counter", :raw => true      # => "24"
	 Rails.cache.clear
     expire_fragment("user_menu_#{@current_user.id}") if @current_user.present?
     expire_fragment("admin_true") #if fragment_exist?("admin_true")
     expire_fragment("admin_false") #if fragment_exist?("admin_false")
     expire_fragment("header_logo")
     expire_fragment("dashboard_menu")

      expire_fragment("header_right_menu_admin_true")
      expire_fragment("header_right_menu_admin_false")
      
      expire_fragment("user_menu_true}")
      

      expire_action :controller => "home", :action => 'terms'
      expire_action :controller => "home", :action => 'privacy'
      expire_action :controller => "home", :action => 'security'
      expire_action :controller => "home", :action => 'index'
      
      redirect_to "/"
  end
  
  def api_contact_us
   xml_start_node = "<message>"
   xml_end_node = "</message>"
   if (params[:email] != "") && (params[:name] != "") && (params[:message] != "") &&  (params[:phone] != "") 
      build_contact_us_info(params[:email],params[:name],params[:message], params[:phone], true)
      msg = xml_start_node +"<success>Successfully saved the contact us information.</success>"+ xml_end_node
   else
      msg = xml_start_node +"<error>Error while saving contact us information.</error>"+ xml_end_node
   end
   respond_to do |format|
      format.json  { render :json => Hash.from_xml(msg).to_json }  
   end
 end
  
 def send_latest_blog_mail
   source = 'http://blog.andolasoft.com/wp-admin/api.php'
   resp = Net::HTTP.get_response(URI.parse(source))
   data = resp.body
   result = JSON.parse(data)
   guid = result["guid"]
   title = result["post_title"]
   content = result["post_content"].gsub!(/\n/, '<br>').gsub! "<img", "<img style='max-width:800px !important;'"
   send_all = params[:send_all].present? ? false : true
   LatestBlogNotification.perform_async("#{guid}","#{title}","#{content}","#{send_all}")
   redirect_to "/"
 end
 
 def download_user
    download_user = DownloadUser.create(params[:download_user])
    download_user.update_column(:ip_address,request.remote_ip)
    geo_location = Geocoder.search(request.remote_ip).first
    address = geo_location.present? ? (geo_location.address.present? ? geo_location.address : "N/A") : "N/A"
    
    Notification.send_email_to_downloader(download_user.name,download_user.email).deliver ### Send mail to user
    Notification.send_email_to_admin(download_user.name,download_user.email,address).deliver ### Send mail to admin

    flash[:notice]="Thank you for interest to download WakeUpSales Community Edition! Please use the Download link sent to your email."
    redirect_to "/"
  end
  def report_a_bug
    # @bug_reports = ReportABug.all
    @report_a_bug = ReportABug.new
  end
  def show_bug_report
    @report_a_bug = ReportABug.find(params[:id])
    p "____________________________"
    p @report_a_bug
  end
  def post_comment
    p "#--------------------------============----------------------------#"
    p params
    commentable = ReportABug.find(params[:report_a_bug_id])
    commentable.bug_status = params[:bug_status]
    commentable.save
    comment = commentable.comments.create
    comment.email = params[:email]
    comment.comment = params[:comment]
    comment.save
    redirect_to "/show_bug_report/#{params[:report_a_bug_id]}"
  end
end
