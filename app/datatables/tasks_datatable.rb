  class TasksDatatable
  include ApplicationHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: tasks_info((@user=User.find params[:cuser]), params[:task_status]).select("id").count,
      iTotalDisplayRecords: tasks.present? ? tasks.total_entries : 0,
      aaData: data
    }
  end

private

  def tasks_info(user, task_status,deal_id = "0")
    deal=nil
    if(!deal_id.nil? && !deal_id.blank? && deal_id != "0")
      deal=Deal.find deal_id
    end
    Task.task_list(user, task_status,deal)
  end
  
  def get_priority_color(task)
    clr="green"
    if task.priority_type.present? && task.priority_type.original_id == 1
      clr="red"
    elsif task.priority_type.present? && task.priority_type.original_id == 2
      clr="blue"
    end
    clr
  end
  
  def get_style_bg(task)
    style_bg=""
    style_bg="background:#F5F8FC;" if task.is_completed
  end  
  
  def get_style_text(task)
    style_text=""
    style_text="text-decoration:line-through;" if task.is_completed
  end
  
  def get_datetime(task)
     case params[:task_status]
         when "today"
            task.due_date.strftime("%H:%M")
         when "overdue"
         
         when "upcoming"
            task.due_date.strftime("%a %d %b %Y @ %H:%M")
         when "completed"
     end
  end
  
  def get_datetime_as_per_type(task_type,task)
     case task_type
         when "today"
            task.due_date.strftime("%H:%M")
         when "overdue"
         
         when "upcoming"
            task.due_date.strftime("%a %d %b %Y @ %H:%M")
         when "completed"
     end
  end

  def checkbox_div(task,cuser)
    #status="<input class='task_chk' id='complete_task_#{task.id}' name='complete_task' onclick='task_outcome(#{task.id})' type='checkbox'>"
   # if task.is_completed && cuser.is_admin?
    if task.is_completed && cuser.is_admin?


      status="<input class='task_chk' id='complete_task_#{task.id}' name='complete_task'  onclick='task_outcome(#{task.id})' disabled='disabled' type='checkbox'  checked='checked'>"    
    #elsif task.is_completed && !cuser.is_admin?
    #  status="<input class='task_chk' id='complete_task_#{task.id}' name='complete_task' onclick='task_outcome(#{task.id})' disabled='disabled' type='checkbox' checked='checked'>"
    else
     status="<input class='task_chk' id='complete_task_#{task.id}' name='complete_task' onclick='task_outcome(#{task.id});' type='checkbox'>"
    end
    status
  end
  
  def get_user_name(cuser, task)
    user=task.initiator #User.where("id=?",task.created_by).first
    name=""
    if user.present? && user.id == cuser.id
      name="me"
    elsif user.present?
      name=user.full_name
    end
  end
  
  def get_task_count(counter)
    counter=tasks.select("id").where("is_completed=?", false) if params[:task_status] == "all"
    counter.count
  end
  def data
#    cuser=User.find params[:cuser]
    @count = tasks.count
    @count = tasks.select("id").where("is_completed=?", false).count if params[:task_status] == "all"
    tasks.map do |task|
      deal = task.deal
      [
        h(get_priority_color(task)),
        h(get_style_bg(task)),
        (checkbox_div(task,@user)),
        h(task.id),
        h(task.get_title),
        h(task.due_date.present? ? (task.due_date.strftime("%a %d %b %Y @ %H:%M")) : ""),
        h(task.user.present? ? task.user.full_name : "NA"),
        h(format_date(task.created_at)),
        h(get_user_name(@user, task)),
        h(task.task_note.present? ? task.task_note : ""),
        h(task.task_type.name),
        h(task.is_completed),
        h(task.get_url),
        h(get_style_text(task)),
        h(@count),
         h(task.updated_at.present? ? (task.updated_at.strftime("%a %d %b %Y @ %H:%M")) : ""),
         h(get_datetime(task)),
         #h(get_datetime_as_per_type(task.belongs_to_category, task))
       h(task.due_date.present? ? (get_datetime_as_per_type(task.belongs_to_category, task)) : ""),
       h(task.recurring_type != "none"),
       h(deal.present? && deal.contact_name.present? ? task.deal.contact_name : ""),#19
       h(deal.present? && deal.country_id.present? && deal.current_country.present? ? deal.current_country.name : ''), #20
      ]
    end
  end
  
  def tasks
    @tasks ||= fetch_tasks
  end

  def fetch_tasks
    tasks=tasks_info(@user, params[:task_status],params[:deal_id])
    if tasks.present?
      tasks = tasks.page(page).per_page(per_page)
#      if params[:filter_type].present?
#        if params[:filter_type].include?("0")
#          params[:filter_type].delete("0")
#          if params[:filter_type].present?
#            tasks = tasks.includes(:task_type).where("is_completed = ? AND task_types.id IN (?)", true, params[:filter_type])
#          else

#            tasks = tasks.includes(:task_type).where("is_completed = ?", true)
#          end
#        else


#          tasks = tasks.includes(:task_type).where("task_types.id IN (?)", params[:filter_type])
#        end
#      end
    if params[:t_type].present? && params[:assigned_to].present? 
        tasks=tasks.active_multi_filter_usage_summery(params).page(page).per_page(per_page) 
    else
        tasks=tasks.active_multi_filter(params).page(page).per_page(per_page) if params[:deal_type].present? || params[:asg_to].present? || params[:task_type].present? || params[:dt_range].present?
        tasks=tasks.active_multi_filter_report(params).page(page).per_page(per_page) if params[:assigned_to].present? 
        tasks=tasks.active_multi_filter_usage_summery(params).page(page).per_page(per_page) if params[:t_type].present?
    end
      if params[:sSearch].present?
        tasks = tasks.where("(title like :search)", search: "%#{params[:sSearch]}%")
      end
    end
    tasks
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
