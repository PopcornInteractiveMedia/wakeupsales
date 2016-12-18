class DealsDatatable
  include ApplicationHelper
  include DealsHelper
  include ActionView::Helpers::DateHelper
  
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Deal.count,
      iTotalDisplayRecords: deals.total_entries,
      aaData: data(params[:_type])
    }
  end

 def get_last_task_duedate deal
     #task = Task.select("due_date").where("task_type_id=?", deal.latest_task_type_id).first
	 task = Task.select("due_date").where("deal_id =? and task_type_id=?",deal.id,deal.latest_task_type_id).not_completed.last

     return (task.due_date.strftime("%a %d %b %Y @ %H:%M") if task)
  end
private

  def data(_type)
    cuser =User.find params[:cuser]
    
    case  _type
    when "incoming","junk","qualify", "inactive_deals","all","no_contact","follow_up_required","follow_up","quoted","meeting_scheduled","forecasted","waiting_for_project_requirement","proposal","estimate"
      #deals.includes(:tasks, :deal_labels, :assigned_user, :initiator, :deal_status,:priority_type).includes(:deals_contacts => [{:contactable => {:address => :country }}]).map do |deal|
      #deals.includes([{:contactable=>[:deals_contacts, {:address=>:country}]}, :deals_contacts]).map do |deal|
      
     deals.includes(:last_task, :current_country,:deal_labels, :assigned_user, :initiator, :deal_status,:priority_type).includes(:deals_contacts).map do |deal|
        [
          h(deal.id), #row [0]
          h(deal.title), #row [1]
          #h(format_date(deal.created_at)),
          #h(last_activity_for_deal_json_new(deal.id,cuser)[0].present? ? last_activity_for_deal_json_new(deal.id,cuser)[2]  + " ago": "N/A"), #row [2]
          h(deal.last_activity_date.present? ? distance_of_time_in_words_to_now(deal.last_activity_date)   + " ago": "N/A"), #row [2],
          #h((last_activity=distance_of_time_in_words_to_now(deal.last_activity_date)).present? ? last_activity  + " ago": "N/A"), #row [2]
          h(deal.assigned_user.present? ? ((deal.assigned_user.id == cuser.id) ? "me" : deal.assigned_user.full_name) : ''), #row [3]
          h(deal.attempts), #row [4]
          (deal.deal_labels.map{ |dlb|  [dlb.user_label.color, dlb.user_label.name,dlb.user_label_id]  }), #row [5]
		      #h(deal.collect_contact_names.present? ? deal.collect_contact_names : ""),
          #h(deal.deals_contacts.first.contactable.present? ? deal.deals_contacts.first.contactable.full_name : ""), #row [6]
          h(deal.contact_name.present? ? deal.contact_name : ""), #row [6]
          #h((deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.phones.empty? ? deal.deals_contacts.first.contactable.phones.first.phone_no : '')), #row [7]
          h(deal.contact_phone.present? ? deal.contact_phone : ""), #row [7]
          #h((deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.email.blank? ? deal.deals_contacts.first.contactable.email : '')), #row [8]
          h(deal.contact_email.present? ? deal.contact_email : ""), #row [8]
          h((!deal.priority_type.nil? && deal.priority_type.original_id == 1 ? 'btn-metis-1' : !deal.priority_type.nil? && deal.priority_type.original_id == 2 ? 'btn-metis-2' : 'btn-metis-3')), #row [9]
          [!deal.priority_type.nil? ? deal.priority_type.name : "NA",!deal.priority_type.nil? ? deal.priority_type.id : "NA"], #row [10]
          #h(deal.deals_contacts.first.contactable.present? && deal.deals_contacts.first.contactable.address.present? ? (deal.deals_contacts.first.contactable.address.address.present? ? deal.deals_contacts.first.contactable.address.address : '') : ''), #row [11]
          h(deal.id), #row [11]
          #h(deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.address.nil? && !deal.deals_contacts.first.contactable.address.country.nil? ? deal.deals_contacts.first.contactable.address.country.name : ''), #row [12]
          h(deal.country_id.present? && deal.current_country.present? ? deal.current_country.name : ''), #row [12]
          #h(deal.deals_contacts.first.contactable.present? && !deal.deals_contacts.first.contactable.address.nil? ? deal.deals_contacts.first.contactable.address.city : ''), #row [13]
          h(deal.contact_loc.present? ? deal.contact_loc : ""), #row [13]
          #h(deal.deals_contacts.first.contactable.present? && deal.deals_contacts.first.contactable.id), #row [14]
          h(deal.contacts_id.present? ? deal.contacts_id : ""), #row [14]
          h(date_format(deal.created_at)),  #row [15]
          #h((deal.is_admin_created? && !cuser.is_admin?) ? true : false),
          h((deal.associated_users.include? cuser.id) || (cuser.is_admin? || cuser.is_super_admin?) ? true : false),  #row [16]
          h(!deal.amount.nil? ? deal.amount.to_i : ''), #row [17]
          #h(( deal.deals_contacts &&  deal.deals_contacts.first.contactable && deal.deals_contacts.first.contactable.is_company?) ? "company_contact" : "individual_contact"), #row [18]
          h(deal.contact_type.present? ? deal.contact_type : ""), #row [18]
          h(deal.assigned_to), #row [19]
          h(deal.initiated_by), #row [20]
          h((deal.initiated_by == cuser.id) || (cuser.is_admin?) ? true : false), #row [21]
          h(deal.deal_status_id), #row [22]
          #h( (deal.deals_contacts &&  deal.deals_contacts.first.contactable && deal.deals_contacts.first.contactable.is_company? )? "" : h(deal.collect_company_designaion)), #row [23]
          h(deal.compdesignation.present? ? deal.compdesignation : ""), #row [23]
          h(deal.initiator.present? ? (deal.initiated_by == cuser.id ? "me" : deal.initiator.first_name) : ""), #row [24]
          h(deals.total_entries), #row [25]
          h(deal.deal_status_name), #row [26]
          #h((deal.tasks.last.present? && deal.tasks.last.task_type.present? && !deal.tasks.last.is_completed?) ? deal.tasks.last.task_type.name : "No-Action")#row [27]
          #h((deal.tasks.first.present?) ? (deal.tasks.not_completed.last.present? ? deal.tasks.not_completed.last.task_type.name : "No-Action") : "No-Action"),          
          h(deal.latest_task_type_id.present? ? deal.last_task.name  : "No-Action"),
          #h((deal.tasks.first.present?) ? (deal.tasks.select("due_date").not_completed.last.present? ? deal.tasks.select("due_date").not_completed.last.due_date.strftime("%a %d %b %Y @ %H:%M") : "") : "")
          h(deal.latest_task_type_id.present? ? get_last_task_duedate(deal)  : ""),
          h(deal.is_opportunity),
          !deal.deal_status.nil? ? deal.deal_status.original_id : "NA"
        ]

      end

    when "working"
      deals.includes(:tasks).map do |deal|
        [
          h(deal.id),
          h(deal.title),
          #h(format_date(deal.created_at)),
          #h(last_activity_for_deal_json_new(deal.id,cuser)[0].present? ? last_activity_for_deal_json_new(deal.id,cuser)[2]  + " ago": "N/A"), #row [2]
          h(deal.last_activity_date.present? ? distance_of_time_in_words_to_now(deal.last_activity_date)   + " ago": "N/A"), #row [2],
          #h((last_activity=distance_of_time_in_words_to_now(deal.last_activity_date)).present? ? last_activity  + " ago": "N/A"), #row [2]
          h(deal.assigned_user.present? ? ((deal.assigned_user.id == cuser.id) ? "me" : deal.assigned_user.full_name) : ''),
          h(deal.attempts),
          (deal.deal_labels.map{ |dlb|  [dlb.user_label.color, dlb.user_label.name,dlb.user_label_id]  }),
          #h(deal.collect_contact_names.present? ? deal.collect_contact_names : ""),
		  h(deal.deals_contacts.first.contactable.full_name),
          h((!deal.deals_contacts.first.contactable.phones.empty? ? deal.deals_contacts.first.contactable.phones.first.phone_no : '')),
          h((!deal.deals_contacts.first.contactable.email.blank? ? deal.deals_contacts.first.contactable.email : '')),
          h((deal.priority_type.original_id == 1 ? 'btn-metis-1' : !deal.priority_type.nil? && deal.priority_type.original_id == 2 ? 'btn-metis-2' : 'btn-metis-3')),
          [deal.priority_type.name,deal.priority_type.id],
          h(!deal.deals_contacts.first.contactable.address.nil? ? (!deal.deals_contacts.first.contactable.address.address.nil? && !deal.deals_contacts.first.contactable.address.address.blank? ? deal.deals_contacts.first.contactable.address.address : '') : ''),
          h(!deal.deals_contacts.first.contactable.address.nil? && !deal.deals_contacts.first.contactable.address.country.nil? ? deal.deals_contacts.first.contactable.address.country.name : ''),
          h(!deal.deals_contacts.first.contactable.address.nil? ? deal.deals_contacts.first.contactable.address.city : ''),
          h(deal.deal_status.name),
          (deal.deal_status.original_id == 1 || deal.deal_status.original_id==3 || deal.deal_status.original_id==5) ? "move_deal" : "move_work_deal",
          h(date_format(deal.created_at)),
          h(deal.deals_contacts.first.contactable.id),          

          #h((deal.is_admin_created? && !cuser.is_admin?) ? true : false),
          h((deal.associated_users.include? cuser.id) || (cuser.is_admin? || cuser.is_super_admin?) ? true : false),          
          h(!deal.amount.nil? ? deal.amount.to_i : ''),
          h(deal.deals_contacts.first.contactable.is_company? ? "company_contact" : "individual_contact"),
          h(deal.assigned_to),
          h(deal.initiated_by),
          h((deal.initiated_by == cuser.id) || (cuser.is_admin?) ? true : false),
          h(deal.deal_status_id),
          h(deal.deals_contacts.first.contactable.is_company? ? "" : h(deal.collect_company_designaion)),
          h(deals.total_entries)
        ]
      end
    when "un_assigned"
       deals.includes(:deal_labels, :initiator, :deal_status,:priority_type).includes(:deals_contacts).map do |deal|
        [
          h(deal.id),
          h(deal.title),
          h(deal.last_activity_date.present? ? distance_of_time_in_words_to_now(deal.last_activity_date)   + " ago": "N/A"), #row [2],
          #h((last_activity=distance_of_time_in_words_to_now(deal.last_activity_date)).present? ? last_activity  + " ago": "N/A"), #row [2]
          #h(deal.assigned_user.present? ? ((deal.assigned_user.id == cuser.id) ? "me" : deal.assigned_user.full_name) : ''),
          h(deal.id), #row [3]
          h(deal.attempts),
          (deal.deal_labels.map{ |dlb|  [dlb.user_label.color, dlb.user_label.name,dlb.user_label_id]  }),
          #h(deal.deals_contacts.first.contactable ? deal.deals_contacts.first.contactable.full_name : ""),
          h(deal.contact_name.present? ? deal.contact_name : ""),
          #h(((deal.deals_contacts.first.contactable && deal.deals_contacts.first.contactable.phones.present?) ? deal.deals_contacts.first.contactable.phones.first.phone_no : '')),
          h(deal.contact_phone.present? ? deal.contact_phone : ""),
          #h((!deal.deals_contacts.first.contactable.email.blank? ? deal.deals_contacts.first.contactable.email : '')),
          h(deal.contact_email.present? ? deal.contact_email : ""),
          h((deal.priority_type.original_id == 1 ? 'btn-metis-1' : !deal.priority_type.nil? && deal.priority_type.original_id == 2 ? 'btn-metis-2' : 'btn-metis-3')),
          [deal.priority_type.name,deal.priority_type.id],
          h(deal.id), #row[11]
          #h(!deal.deals_contacts.first.contactable.address.nil? ? (!deal.deals_contacts.first.contactable.address.address.nil? && !deal.deals_contacts.first.contactable.address.address.blank? ? deal.deals_contacts.first.contactable.address.address : '') : ''),

          h(deal.country_id.present? ? deal.current_country.name : ''),
          #h(!deal.deals_contacts.first.contactable.address.nil? ? deal.deals_contacts.first.contactable.address.city : ''),
          h(deal.contact_loc.present? ? deal.contact_loc : ""),
          h(deal.deal_status.name), #row[14]

          #(deal.deal_status.original_id == 1 || deal.deal_status.original_id==3 || deal.deal_status.original_id==5) ? "move_deal" : "move_work_deal",
          h(deal.compdesignation.present? ? deal.compdesignation : ""), #row[15]
          #h(deal.deals_contacts.first.contactable.id),
          h(deal.contacts_id.present? ? deal.contacts_id : ""), #row[16]
          h(deal.amount.present? ? deal.amount : 0),
          #h(deal.probability),
          h(deal.id), #row[18]
          #(!(ph=deal.deals_contacts.first.contactable.phones.find(:first,:conditions=>"phone_type = 'mobile'")).nil? ? ph.extension.nil? ? (deal.deals_contacts.first.contactable.address && deal.deals_contacts.first.contactable.address.country ? deal.deals_contacts.first.contactable.address.country.isd_code : "") : "#{ph.extension} #{ph.phone_no}" : ''),
          h(deal.id), #row[19]
          #(!(ph=deal.deals_contact.contactable.phones.find(:first,:conditions=>"phone_type = 'work'")).nil? ? ph.extension.nil? ? "" : (ph.phone_no.present? ? "#{ph.extension} #{ph.phone_no}" : "") : ''),
          #(!(ph=deal.deals_contacts.first.contactable.phones.find(:first,:conditions=>"phone_type = 'work'")).nil? ? ph.extension.nil? ? (deal.deals_contacts.first.contactable.address && deal.deals_contacts.first.contactable.address.country ? "" : "") : (ph.phone_no.present? ? "#{ph.extension} #{ph.phone_no}" : "")  : ''),
          h(deal.id), #row[20]
          #h(!deal.deals_contacts.first.contactable.name.blank? ? deal.deals_contacts.first.contactable.name : ""),
          h(deal.id), #row[21]
          #h(deal.deals_contacts.first.contactable.attachments.count>0 ? deal.deals_contacts.first.contactable.attachments.last.notes  : ''),
          h(deal.id), #row[22]
          #h(!deal.deal_source.nil? ? deal.deal_source.source.name : ''),
          h(deal.id), #row[23]
          h( deal.initiator.present? ? deal.initiator.full_name : ""),
          h(date_format(deal.created_at)),
          #h((deal.is_admin_created? && !cuser.is_admin?) ? true : false),
          h((deal.associated_users.include? cuser.id) || (cuser.is_admin? || cuser.is_super_admin?) ? true : false),          
          h(deal.deals_contacts.first.contactable.is_company? ? "company_contact" : "individual_contact"),
          h(deal.assigned_to),
          h(deal.initiated_by),
          h((deal.initiated_by == cuser.id) || (cuser.is_admin?) ? true : false),
          h(deal.deal_status_id),
          h(deal.deals_contacts.first.contactable.is_company? ? "" : h(deal.collect_company_designaion)),
          #h((deal.tasks.last.present? && deal.tasks.last.task_type.present? && !deal.tasks.last.is_completed?) ? deal.tasks.last.task_type.name : "No-Action"),
          h((deal.tasks.present?) ? (deal.tasks.where("is_completed = 0").last.present? ? deal.tasks.where("is_completed = 0").last.task_type.name : "No-Action") : "No-Action"),
          h(deals.total_entries), #row[35]
          h(deal.is_opportunity)
         
        ]
      end 
     when "won","lost","not_qualify"
      # p deals
       deals.includes(:last_task,:deal_labels, :assigned_user, :current_country ,:deal_moves,:initiator, :deal_status,:priority_type).includes(:deals_contacts).map do |deal|
        [
          h(deal.id),
          h(deal.title),
          #h(format_date(deal.created_at)),
          #h(last_activity_for_deal_json_new(deal.id,cuser)[0].present? ? last_activity_for_deal_json_new(deal.id,cuser)[2]  + " ago": "N/A"), #row [2]
          h(deal.last_activity_date.present? ? distance_of_time_in_words_to_now(deal.last_activity_date)   + " ago": "N/A"), #row [2],
          #h((last_activity=distance_of_time_in_words_to_now(deal.last_activity_date)).present? ? last_activity  + " ago": "N/A"), #row [2]
          h(deal.assigned_user.present? ? ((deal.assigned_user.id == cuser.id) ? "me" : deal.assigned_user.full_name) : ''),
          h(deal.attempts),
          (deal.deal_labels.map{ |dlb|  [dlb.user_label.color, dlb.user_label.name,dlb.user_label_id]  }),
          #h(deal.deals_contacts.first.contactable.full_name),
          h(deal.contact_name.present? ? deal.contact_name : ""),
          #h((deal.deals_contacts.first.contactable.phones.present? ? deal.deals_contacts.first.contactable.phones.first.phone_no : '')),
          h(deal.contact_phone.present? ? deal.contact_phone : ""),
          #h((!deal.deals_contacts.first.contactable.email.blank? ? deal.deals_contacts.first.contactable.email : '')),
          h(deal.contact_email.present? ? deal.contact_email : ""),
          h((deal.priority_type.original_id == 1 ? 'btn-metis-1' : !deal.priority_type.nil? && deal.priority_type.original_id == 2 ? 'btn-metis-2' : 'btn-metis-3')),
          [deal.priority_type.name,deal.priority_type.id],
          h(deal.id),

          #h(!deal.deals_contacts.first.contactable.address.nil? && !deal.deals_contacts.first.contactable.address.country.nil? ? deal.deals_contacts.first.contactable.address.country.name : ''),
          h(deal.country_id.present? ? deal.current_country.name : ''),
          #h(!deal.deals_contacts.first.contactable.address.nil? ? deal.deals_contacts.first.contactable.address.city : ''),
          h(deal.contact_loc.present? ? deal.contact_loc : ""),
          h(deal.deal_status.name),
          (deal.deal_status.original_id == 1 || deal.deal_status.original_id==3 || deal.deal_status.original_id==5) ? "move_deal" : "move_work_deal",
          #h(deal.deals_contacts.first.contactable.id),
          h(deal.contacts_id.present? ? deal.contacts_id : ""),
          h(deal.amount.present? ? deal.amount : 0),
          h(deal.probability),
          #format_date((deal_obj=deal.deal_moves.where("deal_status_id = ?",(_type =="won" ? cuser.organization.won_deal_status.id : (_type =="lost" ? cuser.organization.lost_deal_status.id  : cuser.organization.not_qualify_deal_status.id))).first).present? ? deal_obj.created_at : Time.zone.now),
          h(deal.id), #row[19]
          #(!(ph=deal.deals_contacts.first.contactable.phones.find(:first,:conditions=>"phone_type = 'mobile'")).nil? ? ph.extension.nil? ? (deal.deals_contacts.first.contactable.address && deal.deals_contacts.first.contactable.address.country ? deal.deals_contacts.first.contactable.address.country.isd_code : "") : "#{ph.extension} #{ph.phone_no}" : ''), #row[20]
          h(deal.id), #row[20]
          #(!(ph=deal.deals_contact.contactable.phones.find(:first,:conditions=>"phone_type = 'work'")).nil? ? ph.extension.nil? ? "" : (ph.phone_no.present? ? "#{ph.extension} #{ph.phone_no}" : "") : ''),
          #(!(ph=deal.deals_contacts.first.contactable.phones.find(:first,:conditions=>"phone_type = 'work'")).nil? ? ph.extension.nil? ? (deal.deals_contacts.first.contactable.address && deal.deals_contacts.first.contactable.address.country ? "" : "") : (ph.phone_no.present? ? "#{ph.extension} #{ph.phone_no}" : "")  : ''), row[21]
          h(deal.id), #row[21]
          #h(!deal.deals_contacts.first.contactable.name.blank? ? deal.deals_contacts.first.contactable.name : ""),
          h(deal.id), #row[22]
          #h(deal.deals_contacts.first.contactable.attachments.count>0 ? deal.deals_contacts.first.contactable.attachments.last.notes  : ''),
          h(deal.id), #row[23]
          #h(!deal.deal_source.nil? ? deal.deal_source.source.name : ''),
          h(deal.id), #row[24]
          h( deal.initiator.present? ? deal.initiator.full_name : ""),
          h(deal.created_at.strftime("%b %d, %Y")),
          #h((deal.is_admin_created? && !cuser.is_admin?) ? true : false),
          h((deal.associated_users.include? cuser.id) || (cuser.is_admin? || cuser.is_super_admin?) ? true : false),          
          #h(deal.deals_contacts.first.contactable.is_company? ? "company_contact" : "individual_contact"),
          h(deal.contact_type.present? ? deal.contact_type : ""), #row[28]
          h(deal.assigned_to),
          h(deal.initiated_by),
          h((deal.initiated_by == cuser.id) || (cuser.is_admin?) ? true : false),
          h(deal.deal_status_id),
          #h(deal.deals_contacts.first.contactable.is_company? ? "" : h(deal.collect_company_designaion)),
          h(deal.compdesignation.present? ? deal.compdesignation : ""),
          #h((deal.tasks.last.present? && deal.tasks.last.task_type.present? && !deal.tasks.last.is_completed?) ? deal.tasks.last.task_type.name : "No-Action"),
          #h((deal.tasks.present?) ? (deal.tasks.where("is_completed = 0").last.present? ? deal.tasks.where("is_completed = 0").last.task_type.name : "No-Action") : "No-Action"),
          h(deal.latest_task_type_id.present? ? deal.last_task.name  : "No-Action"),
          h(deals.total_entries), #row[35]
          move_date(deal),
          #h((deal.tasks.first.present?) ? (deal.tasks.select("due_date").not_completed.last.present? ? deal.tasks.select("due_date").not_completed.last.due_date.strftime("%a %d %b %Y @ %H:%M") : "") : "")
          h(deal.latest_task_type_id.present? ? get_last_task_duedate(deal)  : ""),
          h(deal.is_opportunity)
        ]
      end
    end 
    #format_date(!(dm=deal.deal_moves.where(:deal_status_id=>(_type =="won" ? cuser.organization.won_deal_status.id : _type=="lost" ? cuser.organization.lost_deal_status.id : cuser.organization.not_qualify_deal_status.id ))[0]).nil? ? dm.created_at : Time.now),
    #format_date(deal.deal_moves.where("deal_status_id = ?",(_type =="won" ? cuser.organization.won_deal_status.id : (_type =="lost" ? cuser.organization.lost_deal_status.id  : cuser.organization.not_qualify_deal_status.id)))[0].created_at),
    #+ " " + deal.deals_contact.contactable.address.country.name + " "+contact.address.city
  end
  
  def move_date deal
    p deal
    p deal.id
    p deal.stage_move_date
    puts "_)_)__)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)_)"
    deal.stage_move_date.strftime("%b %d, %Y") if deal.stage_move_date.present?
  end
  
  def deals
  puts "coming to datatable"
    @deals ||= fetch_deals
  end


  def fetch_deals
    puts "---------------fetch deals"
    p params[:filtervalue]
    p params[:filtertype]
   # ss
    cuser =User.find params[:cuser]
    filtervalue = params[:filtervalue]
    filtertype = params[:filtertype]
    cre_by = params[:cre_by]
    cre_by_val = params[:cre_by_val]
    asg_by = params[:asg_by]
    asg_by_val = params[:asg_by_val]
    loc = params[:loc]
    loc_val = params[:loc_val]
    priority = params[:priority]
    priority_val = params[:priority_val]
    next_t = params[:next]
    next_val = params[:next_val]
    daterange = params[:daterange]
    dt_range = params[:dt_range]
    stage = params[:stage]
    stage_val = params[:stage_val]   
    if(params[:q] == "1")
      @start_date = DateTime.new(params[:y].to_i,1,1)
      @end_date = DateTime.new(params[:y].to_i,3,31)     
    elsif(params[:q] == "2")
      @start_date = DateTime.new(params[:y].to_i,4,1)
      @end_date = DateTime.new(params[:y].to_i,6,30)     
    elsif(params[:q] == "3")
      @start_date = DateTime.new(params[:y].to_i,7,1)
      @end_date = DateTime.new(params[:y].to_i,9,30)     
    elsif(params[:q] == "4")
     @start_date = DateTime.new(params[:y].to_i,10,1)
     @end_date = DateTime.new(params[:y].to_i,12,31)     
    end
    
    if(cuser.is_super_admin? || cuser.is_admin?)
      case params[:_type]
        when 'inactive_deals'
          @dls=[]
#          if params[:assigned_to].present? && (params[:assigned_to] == "me" || (user=cuser.organization.users.where("id=?",  params[:assigned_to]).first).present?)
#            user=params[:assigned_to] == "me" ? cuser : user
#            deal_ids=user.attention_deal.deal_ids
#            @dls = Deal.where("deals.id IN (?)", deal_ids) if deal_ids.present?
#            if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
#              @dls = @dls.by_label(filtervalue)
#            elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
#              @dls = @dls.by_priority(filtervalue)
#            end
#          elsif params[:created_by].present? && (user=cuser.organization.users.where("id=?",  params[:created_by]).first).present?
#            
#            deal_ids=user.attention_deal.deal_ids
#            @dls = Deal.where("deals.id IN (?)", deal_ids) if deal_ids.present?
#            if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
#              @dls = @dls.by_label(filtervalue)
#            elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
#              @dls = @dls.by_priority(filtervalue)
#            end
#          elsif active_multifilter?
          if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            
            deal_ids=cuser.attention_deal.deal_ids
            @dls = Deal.where("deals.id IN (?)", deal_ids) if deal_ids.present?
            @dls = @dls.active_multi_filter(params)
          else
            deal_ids=cuser.attention_deal.deal_ids
            @dls = Deal.where("deals.id IN (?)", deal_ids) if deal_ids.present?
            if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
              @dls = @dls.by_label(filtervalue)
            elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
              @dls = @dls.by_priority(filtervalue)
            end
#            @dls = @dls.where("is_active=? AND (is_current IS NULL OR is_current =?) AND deal_status_id=?", true, false, cuser.organization.incoming_deal_status().id)
          end
          
        when 'incoming'
          query_condition_incomming=[]
          #query_condition_incomming.where(:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
          query_condition_incomming.where("is_remote = 0 and is_active = 1 and deal_status_id=? and organization_id =?", cuser.organization.incoming_deal_status().id, cuser.organization_id)
          if params[:assigned_to].present? && (params[:assigned_to] == "me" || (user=cuser.organization.users.where("id=?",  params[:assigned_to]).first).present?)        
            user=params[:assigned_to] == "me" ? cuser : user
           
            if (params[:q].present? && params[:y].present?) && (!@start_date.nil? && !@end_date.nil?)
              @dls = user.all_assigned_deal.by_range(@start_date,@end_date).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
              params[:dl_count] = @dls.count
            else          
              @dls = user.all_assigned_deal
              params[:dl_count] = nil
            end
            if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
              @dls = @dls.by_label(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
              @dls = @dls.by_priority(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            else
              @dls = @dls.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            end
          elsif !params[:assigned_to].present? && (params[:q].present? && params[:y].present?)          
            @dls = cuser.organization.deals.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id).by_range(@start_date,@end_date)            
          elsif params[:created_by].present? && (user=cuser.organization.users.where("id=?",  params[:created_by]).first).present?
            @dls = user.my_created_deals
            if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
              @dls = @dls.by_label(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
              @dls = @dls.by_priority(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            else
              @dls = @dls.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            end
          elsif active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.organization.deals.active_multi_filter(params)
            if params[:dt_range].present? && params[:dt_range] == "3m"
               @dls=@dls.last_three_months.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id) if @dls.present?
            else
               @dls=@dls.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id) if @dls.present?
            end
          else
            if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
              @dls = cuser.organization.deals.by_label(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
              @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
            else            
              #@dls = Deal.where(query_condition_incomming).where(:organization_id => cuser.organization_id)
			  @dls = Deal.where(query_condition_incomming)
            end

          end
          
          
        when 'working'
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:is_current=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:is_current=>true)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:is_current=>true)
          end
        when 'un_assigned'
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where("is_remote = ? and is_active = ? and hot_lead_token is NULL",true,true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where("is_remote = ? and is_active = ? and hot_lead_token is NULL",true,true)
          else
            @dls = cuser.organization.deals.where("is_remote = ? and is_active = ? and hot_lead_token is NULL",true,true)
          end
        when 'qualify'
          if active_multifilter?
           params[:assigned_to]=nil
           params[:created_by]=nil
           @dls = cuser.organization.deals.active_multi_filter(params)
           @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id) if @dls.present?
          elsif (params[:q].present? && params[:y].present?) && (!@start_date.nil? && !@end_date.nil?)
           @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id).by_range(@start_date,@end_date)
         else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id)
          end
         end
        when 'not_qualify'
         if active_multifilter?
           params[:assigned_to]=nil
           params[:created_by]=nil
           @dls = cuser.organization.deals.active_multi_filter(params)
           @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id) if @dls.present?
         else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id)
          end
         end
        when 'won'
         if active_multifilter?
           params[:assigned_to]=nil
           params[:created_by]=nil
           @dls = cuser.organization.deals.active_multi_filter(params)
           @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id) if @dls.present?
        # elsif (params[:q].present? && params[:y].present?) && (!params[:q].nil? && !params[:y].nil? )   
         elsif (!params[:q].nil? && !params[:y].nil?) && (!@start_date.nil? && !@end_date.nil?)

           @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id).by_range(@start_date,@end_date) #if !@start_date.nil? && !@end_date.nil?
         
         else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id)
          end
         end
        when 'lost'
         if active_multifilter?
           params[:assigned_to]=nil
           params[:created_by]=nil
           @dls = cuser.organization.deals.active_multi_filter(params)
           @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id) if @dls.present?
         elsif (params[:q].present? && params[:y].present?) && (!@start_date.nil? && !@end_date.nil?)
           @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id).by_range(@start_date,@end_date)
         else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id)
          end
         end
        when 'junk'
         if active_multifilter?
           params[:assigned_to]=nil
           params[:created_by]=nil
           @dls = cuser.organization.deals.active_multi_filter(params)
           @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id) if @dls.present?
         else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id)
          end
         end
        when 'nocontact','no_contact','follow_up_required','follow_up','quoted','meeting_scheduled','forecasted','waiting_for_project_requirement','proposal','estimate'
          if active_multifilter?
           params[:assigned_to]=nil
           params[:created_by]=nil
           @dls = cuser.organization.deals.active_multi_filter(params)
           @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id) if @dls.present?
         else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "stage")
            @dls = cuser.organization.deals.by_stage(filtervalue).where(:is_active=>true)
          else
            @dls = cuser.organization.deals.where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id)
          end
         end
        when 'all'
        puts "alllllldeepakllllllllllllllllll"
          if active_multifilter?
           params[:assigned_to]=nil
           params[:created_by]=nil
           @dls = cuser.organization.deals.active_multi_filter(params)
           @dls=@dls.where(:is_active=>true) if @dls.present?
         else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "stage")
            @dls = cuser.organization.deals.by_stage(filtervalue).where(:is_active=>true)
          else
            @dls = cuser.organization.deals.where(:is_active=>true)
          end
         end
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.organization.deals.by_label(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.organization.deals.by_priority(filtervalue).where(:is_active=>true)
          else
            @dls = cuser.organization.deals.where(:is_active=>true)
          end
        end
    else
      case params[:_type]
       when 'inactive_deals'
          if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            deal_ids=cuser.attention_deal.deal_ids
            @dls = Deal.where("deals.id IN (?)", deal_ids) if deal_ids.present?
            @dls = @dls.active_multi_filter(params)
          else
            deal_ids=cuser.attention_deal.deal_ids
            @dls = Deal.where("deals.id IN (?)", deal_ids) if deal_ids.present?
            if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
              @dls = @dls.by_label(filtervalue)
            elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
              @dls = @dls.by_priority(filtervalue)
            end
#            @dls = @dls.where("is_active=? AND (is_current IS NULL OR is_current =?) AND deal_status_id=?", true, false, cuser.organization.incoming_deal_status().id)
          end
	    
        when 'incoming'
          if params[:assigned_to].present?  && (params[:assigned_to] == "me" || (user=cuser.organization.users.where("id=?",  params[:assigned_to]).first).present?)
            user=params[:assigned_to] == "me" ? cuser : user
            @dls = user.all_assigned_deal
          elsif params[:created_by].present?  && (params[:created_by] == "me" || (user=cuser.organization.users.where("id=?",  params[:created_by]).first).present?)
          # elsif params[:created_by].present? && (user=cuser.organization.users.where("id=?",  params[:created_by]).first).present?
        
            user=params[:created_by] == "me" ? cuser : user
            @dls = user.my_created_deals
          else
            @dls = cuser.all_deals
          end
          if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            if params[:dt_range].present? && params[:dt_range] == "3m"
              @dls = cuser.all_assigned_deal.active_multi_filter(params)
            else
              @dls = cuser.all_deals.active_multi_filter(params)
            end
            if params[:dt_range].present? && params[:dt_range] == "3m"
               @dls=@dls.last_three_months.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id) if @dls.present?
            else
               @dls=@dls.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id) if @dls.present?            
            end
          end
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = @dls.by_label(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = @dls.by_priority(filtervalue).where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
          else
            @dls = @dls.where(:is_remote=>false,:is_active=>true,:deal_status_id=>cuser.organization.incoming_deal_status().id)
          end
        when 'working'
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.all_assigned_deal.by_label(filtervalue).where(:is_active=>true,:is_current=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.all_assigned_deal.by_priority(filtervalue).where(:is_active=>true,:is_current=>true)
          else
            @dls = cuser.all_assigned_deal.where(:is_active=>true,:is_current=>true)
          end
         when 'un_assigned'
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.all_assigned_deal.by_label(filtervalue).where(:is_remote=>true,:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.all_assigned_deal.by_priority(filtervalue).where(:is_remote=>true,:is_active=>true)
          else
            @dls = cuser.all_assigned_deal.where(:is_remote=>true,:is_active=>true)
          end
          
        when 'qualify'
        if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.my_deals.active_multi_filter(params)
            @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id) if @dls.present?
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id)
          else
            @dls = cuser.my_deals.where(:is_active=>true,:deal_status_id=>cuser.organization.qualify_deal_status().id)
          end
        end
        when 'not_qualify'
         if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.my_deals.active_multi_filter(params)
            @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id) if @dls.present?
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id)
          else
            @dls = cuser.my_deals.where(:is_active=>true,:deal_status_id=>cuser.organization.not_qualify_deal_status().id)
          end
        end
        when 'won'
         if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.my_deals.active_multi_filter(params)
            @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id) if @dls.present?
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id)
          else
            @dls = cuser.my_deals.where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id)
          end
        end
        when 'lost'
         if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.my_deals.active_multi_filter(params)
            @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id) if @dls.present?
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.lost_deal_status().id)
          else
            @dls = cuser.my_deals.where(:is_active=>true,:deal_status_id=>cuser.organization.won_deal_status().id)
          end
         end
        when 'junk'
         if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.my_deals.active_multi_filter(params)
            @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id) if @dls.present?
        else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id)
          else
            @dls = cuser.my_deals.where(:is_active=>true,:deal_status_id=>cuser.organization.junk_deal_status().id)
          end
         end
        when 'nocontact','no_contact','follow_up_required','follow_up','quoted','meeting_scheduled','forecasted','waiting_for_project_requirement','proposal','estimate'
          if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.my_deals.active_multi_filter(params)
            @dls=@dls.where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id) if @dls.present?
          else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id)
          else
            @dls = cuser.my_deals.where(:is_active=>true,:deal_status_id=>cuser.organization.get_deal_status(params[:_type]).id)
          end
         end 
        when 'all'
          puts "allllllllllllllllllllllll"
          if active_multifilter?
            params[:assigned_to]=nil
            params[:created_by]=nil
            @dls = cuser.my_deals.active_multi_filter(params)
            @dls=@dls.where(:is_active=>true) if @dls.present?
          else
          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "stage")
            @dls = cuser.my_deals.by_stage(filtervalue).where(:is_active=>true)
          else
            @dls = cuser.my_deals.where(:is_active=>true)
          end
         end 
        else

          if(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "label")
            @dls = cuser.my_deals.by_label(filtervalue).where(:is_active=>true)
          elsif(!filtervalue.nil? && !filtervalue.blank? && filtervalue != "0" && filtertype == "priority")
            @dls = cuser.my_deals.by_priority(filtervalue).where(:is_active=>true)
          else
            @dls = cuser.my_deals.where(:is_active=>true)
          end
          
        end
    end
    
    
   # query_condition_incomming
    #deals = @dls.order("last_activity_date desc").order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    
    
    if params[:filtervalue] == "opportunity"
     @dls = @dls.where(:is_opportunity=>true)
    end
     if params[:tag].present?
       @dls = @dls.tagged_with(params[:tag])
     end


    if(sort_column == "title" || sort_column == "country_id" || sort_column == "created_at" || sort_column == "stage_move_date" || sort_column == "amount" || sort_column == "priority_type_id" || sort_column == "deal_status_id"  )
     deals = @dls.reorder(nil).order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    else
      deals = @dls.order("last_activity_date desc").order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    end
    #deals = @dls.order("#{sort_column} #{sort_direction}").order("last_activity_date desc").page(page).per_page(per_page)
    #deals = @dls.order("last_activity_date desc").order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    #deals = deals.page(page).per_page(per_page)
	#deals = deals.includes({:deals_contacts=>{:contactable=>[{:address=>:country},:phones,:attachments]}},:deal_moves,:initiator,:deal_source,:assigned_user,:deal_labels,:deal_status).page(page).per_page(per_page)
 # deals = deals.includes(:deal_moves,:initiator,:deal_source,:assigned_user,:deal_labels,:deal_status).page(page).per_page(per_page)
  
  
   deals = deals.page(page).per_page(per_page)
  
	#deals = deals.includes(:deal_moves,:initiator,:deal_source,:assigned_user,:deal_labels,:priority_type,:deal_status).page(page).per_page(per_page)
	  #deals = deals.page(page).per_page(per_page)
	

    if params[:sSearch].present?
      deals = deals.where("title like :search ", search: "%#{params[:sSearch]}%")
    end
    deals
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

 def sort_column
    if(params[:_type] == "incoming" || params[:_type] == "qualify"  || params[:_type] == "no_contact" || params[:_type] == "follow_up_required" || params[:_type] == "follow_up" || params[:_type] == "quoted" || params[:_type] == "meeting_scheduled" || params[:_type] == "forecasted" || params[:_type] == "waiting_for_project_requirement" || params[:_type] == "proposal" || params[:_type] == "estimate")
	   columns = %w[deals.id title created_at country_id created_at amount amount priority_type_id]
    elsif params[:_type] == "working"
	    columns = %w[deals.id title created_at amount id id email priority_type_id deal_status_id country_id]
	   elsif params[:_type] == "un_assigned"
      columns = %w[deals.id title created_at amount id id email priority_type_id deal_status_id country_id]
	  elsif params[:_type] == "won"
	    columns = %w[deals.id title id created_at stage_move_date amount id]
	  elsif params[:_type] == "not_qualify"
	    #columns = %w[deals.id title created_at id priority_type_id amount]
	    columns = %w[deals.id title id created_at amount id priority_type_id]
	  elsif  params[:_type] == "lost"
	    columns = %w[deals.id title id created_at id priority_type_id]
    elsif  params[:_type] == "all"
	   columns = %w[deals.id title created_at country_id deal_status_id amount amount priority_type_id]
    
      
    else
      
      columns = %w[deals.id title id country_id created_at id priority_type_id]
    end
    columns[params[:iSortCol_0].to_i]
    puts "---------------------------- columns"
    p columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
  
  private
  def active_multifilter?
    params[:cre_by].present? || params[:cre_by_val].present? || params[:asg_by].present? || params[:asg_by_val].present? || params[:loc].present? || params[:loc_val].present? || params[:priority].present? || params[:priority_val].present?|| params[:next].present? || params[:next_val].present? || params[:daterange].present? || params[:dt_range].present? || params[:last_touch].present? || params[:last_tch].present?  || params[:dt_range_from].present? || params[:dtrange_from].present? || params[:dtrange_to].present? || params[:dt_range_to].present? || params[:is_opportunity].present? || params[:tag].present? || params[:stage].present? || params[:stage_val].present? || params[:label_type].present?
  end
end

