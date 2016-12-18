module TasksHelper
  
  def badge_all(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks = tasks.where("is_completed=? ", false)
    #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
    tasks=tasks.where("(tasks.assigned_to=? )", current_user.id) unless current_user.is_admin?
   tasks.count
  end
  
  def badge_today(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks if current_user.organization.present? && current_user.organization.tasks.present?
    else
      tasks= get_tasks(taskable, taskable_id)
    end
	if tasks
		tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
	   #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
	   
	   tasks=tasks.where("(tasks.assigned_to=?)", current_user.id) unless current_user.is_admin?
	   tasks.count
	 end  
  end
  
  def badge_overdue(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks if current_user.organization.present? && current_user.organization.tasks.present?
    else
      tasks= get_tasks(taskable, taskable_id)
    end
	if tasks
      tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
      #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
      tasks=tasks.where("(tasks.assigned_to=?)", current_user.id) unless current_user.is_admin?
      tasks.count
	end  
  end
  
  def badge_upcoming(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks if current_user.organization.present? && current_user.organization.tasks.present?
    else
      tasks= get_tasks(taskable, taskable_id)
    end
	if tasks
    tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
    #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
    tasks=tasks.where("(tasks.assigned_to=? )", current_user.id) unless current_user.is_admin?
    tasks.count
   end
  end
  
  def badge_completed(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks = tasks.where("is_completed=? ", true)
    #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
    tasks=tasks.where("(tasks.assigned_to=?)", current_user.id) unless current_user.is_admin?
   tasks.count
  end
  
  def get_tasks(taskable=nil, taskable_id=nil)
    if taskable == "Deal"
      taskable_obj = Deal.find taskable_id
    elsif taskable == "Contact"
      taskable_obj = Contact.find taskable_id
    end
    taskable_obj.tasks
  end
  
  def badge_today_user(user, taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
   tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) unless user.is_admin?
   tasks.count
  end
  
  def badge_overdue_user(user, taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
    tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) unless user.is_admin?
   tasks.count
  end
  
  def badge_upcoming_user(user, taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
    tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) unless user.is_admin?
   tasks.count
  end
  
  def badge_all_user(user, taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks= user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks = tasks.where("is_completed=? ", false)
    tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) unless user.is_admin?
   tasks.count
  end
  def badge_all_deal(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks
    else
     tasks= get_tasks(taskable, taskable_id)
    end
    tasks = tasks.where("is_completed=? ", false)
    #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
    #tasks=tasks.where("(tasks.assigned_to=? )", current_user.id) unless current_user.is_admin?
    
   tasks.count

   
  end
  
  def badge_today_deal(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
   #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
   
   #tasks=tasks.where("(tasks.assigned_to=?)", current_user.id) unless current_user.is_admin?
   tasks.count
  end
  
  def badge_overdue_deal(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
    #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
    #tasks=tasks.where("(tasks.assigned_to=?)", current_user.id) unless current_user.is_admin?
   tasks.count
  end
  
  def badge_upcoming_deal(taskable=nil, taskable_id=nil)
    unless taskable.present?
      tasks=current_user.organization.tasks
    else
      tasks= get_tasks(taskable, taskable_id)
    end
    tasks=tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
    #tasks=tasks.where("(tasks.assigned_to=? OR tasks.created_by=?)", current_user.id, current_user.id) unless current_user.is_admin?
    #tasks=tasks.where("(tasks.assigned_to=? )", current_user.id) unless current_user.is_admin?
   tasks.count
  end
end
