class Deal < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :organization
  belongs_to :priority_type
  belongs_to :contact, :class_name=>"Contact"
#  belongs_to :individual_contact, :foreign_key=> "contact_ref_id"
#  belongs_to :company_contact, :foreign_key=> "contact_ref_id"
  belongs_to :assigned_user, :class_name=>"User",:foreign_key=>"assigned_to"
  belongs_to :initiator, :class_name=>"User",:foreign_key=>"initiated_by"
  #belongs_to :assigned_to, :class_name=>"User",:foreign_key=>"assigned_to"
  has_one :deal_source, :class_name=>"DealSource"
  has_one :deal_industry, :class_name=>"DealIndustry"
  #has_many :attachments,:class_name=>"Note",:as=>:notable
  belongs_to :deal_status,:class_name=>"DealStatus"
  has_many :tasks
  has_many :deal_labels
  has_many :deal_moves
  has_many  :deals_contacts, :dependent => :destroy
  has_many :activities, :class_name=>"Activity", :dependent => :destroy,:foreign_key=>"source_id"
  has_many :mail_letters, :as => :mailable
  belongs_to :current_country, :class_name=>"Country",:foreign_key=>"country_id"
  belongs_to :last_task, :class_name=>"TaskType",:foreign_key=>"latest_task_type_id"
  
  serialize :contact_info, JSON
  
  #include Tire::Model::Search
  #include Tire::Model::Callbacks

  attr_accessible :is_current,:is_active,:contact,:amount, :attempts, :initiated_by, :is_public, 
          :probability, :title, :assigned_to, :priority_type,:deal_status_id,:deal_status,:created_at, :is_csv, :is_mail_sent,
          :last_activity_date, :comments,:latest_task_type_id, :contact_info, :duration, :billing_type, 
          :stage_move_date, :tag_list, :hot_lead_token, :token_expiry_time, :next_priority_id, :assignee_id, :is_remote,:payment_status,:referrer,:visited,:location_by_api, :individual_contact_id

          
  attr_accessor :country,:work_phone,:contact_id,:file_description,
    :created_by, :email, :facebook_url, :first_name, :last_name, :linkedin_url, :messanger_id, 
    :messanger_type, :name, :twitter_url, :website,:company_strength_id,:contact_type,
    :address,:city,:state,:zip_code,:mobile_number,:image,:notes,:company_strength,:full_address,:monthly_avg, :move_deal,:activities_count
  acts_as_taggable
    
  #after_create :send_email,:insert_deal_activity
  after_save :update_country_id
  after_save :update_stage_move_date, :if => :deal_status_id_changed?
  after_update :reassign_actvity, :if => :assigned_to_changed?
#  before_create :update_stage_move_date
  before_save :set_tag_owner #, :if => :deal_tag_list_changed?
  
  
  
  scope :by_label, lambda{|type|joins(:deal_labels).where("user_label_id   = ? ", type)}  
  scope :by_priority, lambda{|type| where("priority_type_id   = ? ", type)}  
  scope :by_stage, lambda{|type| where("deal_status_id   = ? ", type)}  
  scope :by_is_active, lambda {where("is_active = ?", true)}  
  scope :within_four_weeks, lambda{ where('deals.created_at >= ?', 4.weeks.ago)}  
  scope :in_last_month, lambda{ where(:created_at => 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :in_current_month, lambda{ where('deals.created_at BETWEEN ? AND ?', DateTime.now.in_time_zone.beginning_of_month, DateTime.now.in_time_zone.end_of_month) }
  scope :created_and_assigned, lambda{|id| where("initiated_by = ? or assigned_to = ?", id,id)}
  scope :by_range, lambda{ |start_date, end_date| where(:created_at => start_date..end_date) }
  scope :last_three_months, lambda{ where('deals.created_at >= ?', 3.months.ago)}  
  
  def set_tag_owner

    #if self.tag_list_changed?

    unless self.move_deal
        # Set the owner of some tags based on the current tag_list
        set_owner_tag_list_on(self.organization, :tags, self.tag_list)
        # Clear the list so we don't get duplicate taggings
        self.tag_list = nil
    end
 end
  
  def all_tags
    tags.map(&:name).join(", ") 
  end
  
  def update_stage_move_date
    self.update_column :stage_move_date, Time.now
    
    if self.deal_status_id == self.organization.won_deal_status().id
       ids = []
       self.deals_contacts.map { |contact| 
            if  contact.contactable.is_individual?
                ids << contact.contactable.id
            end
        }
        if ids.present?
           IndividualContact.where(id: ids.uniq).update_all(is_customer: true)
        end
    end
  end
  
  def run_in_background
    InsertOpportunity.perform_async("#{self.id}")    
  end
  
  
  def reassign_actvity    
     self.update_column :last_activity_date, Time.zone.now
     Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.assigned_to,:activity_type=> self.class.name, :activity_id => self.id, :activity_status => "Re-assign",:activity_desc=>self.title,:activity_date => self.last_activity_date, :is_public => (self.is_public.nil? ||  self.is_public.blank?) ? false : self.is_public, :source_id => self.id,:activity_by => User.current.id)
     self.update_column(:is_remote, false) unless self.assigned_to.present?
  end
  
  def insert_deal_activity
   de_a = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.assigned_to,:activity_type=> "Deal", :activity_id => self.id, :activity_status => "Assign",:activity_desc=>self.title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.id)
   de_c = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.initiated_by,:activity_type=> "Deal", :activity_id => self.id, :activity_status => "Create",:activity_desc=>self.title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.id)
   if(self.deals_contacts.last.contactable_type == "IndividualContact")
    con_type = "IndividualContact"
   else
    con_type = "CompanyContact"
   end
   ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_c.id,:contactable_type=>con_type,:contactable_id=> self.deals_contacts.last.contactable_id)
   ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_a.id,:contactable_type=>con_type,:contactable_id=> self.deals_contacts.last.contactable_id)
   self.update_column :last_activity_date,  de_a.activity_date  
 end
  
  ##After create/update the deal country id will be updated as per the first contact information country
  def update_country_id  
      self.update_column :last_activity_date, Time.zone.now
      
       puts "---------------------End ---- updaing countryid---------------"
       unless self.move_deal
         puts "------------------contact info changed"
         if self.deals_contacts.first
           if (contact_infos=self.deals_contacts.first).present? && contact_infos.contactable.present? &&  (address_info=contact_infos.contactable.address).present?
              self.update_column(:country_id, address_info.country_id)
            end  
           #d = self
             name = (self.deals_contacts.first.contactable.present? ? self.deals_contacts.first.contactable.full_name : "")
            id = (self.deals_contacts.first.present? ? self.deals_contacts.first.contactable_id : "")
            type = ((deal_contactable=self.deals_contacts.first.contactable).present? && deal_contactable.is_company? ? "company_contact" : "individual_contact")
            phone = (self.deals_contacts.first.contactable.present? && self.deals_contacts.first.contactable.phones.first.present? ? self.deals_contacts.first.contactable.phones.first.phone_no : "")
            email = (self.deals_contacts.first.contactable.present? ? self.deals_contacts.first.contactable.email : "")
            comp_desg = (self.deals_contacts.present? &&  self.deals_contacts.first.contactable.present? && self.deals_contacts.first.contactable.is_company? ? "" : self.collect_company_designaion)
            
            loc= (self.deals_contacts.first.contactable.present? && !self.deals_contacts.first.contactable.address.nil? ? self.deals_contacts.first.contactable.address.city : '')
            
            #@s = self.contact_info = {"name"=>name,"id"=>id,"type"=> type,"phone"=>phone,"email"=>email,"comp_desg"=>comp_desg,"loc"=>loc}
            @s = {"name"=>name,"id"=>id,"type"=> type,"phone"=>phone,"email"=>email,"comp_desg"=>comp_desg,"loc"=>loc}
		   self.update_column(:contact_info,@s.to_json)
          end
       end
      end
  
  def send_email
    puts "---------------------------------------sending mail from model ---------------"
    self.update_column :last_activity_date, Time.zone.now
    if assigned_user.present? && assigned_user.email
    email = assigned_user.email
    name = assigned_user.full_name
    title = self.title
    deal_id = self.id
  #if (assigned_user.email_notification.nil?) || (assigned_user.email_notification && assigned_user.email_notification.deal_assign == true && assigned_user.email_notification.donot_send == false)
    #Notification.send_deal_info(assigned_user, initiator.full_name, self ).deliver 
    SendEmailNotificationDeal.perform_async(email,name,initiator.full_name,title,deal_id)
  #end
  
    deal_is_opportunity = check_deal_is_opportunity(self.id)
    deal_is_opportunity.call()
  
  end
  end
  #mapping do
   # indexes :image_url
    #indexes :class_name
    #indexes :initiator_name
    #indexes :assigned_user_name
    #indexes :contacts_name
    #indexes :contacts_email
    #indexes :contacts_phone_no
  #end
  
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
     :methods   => [:image_url, :initiator_name, :assigned_user_name, :contacts_name, :contacts_email, :contacts_phone_no]
    )
  end
  
  def is_admin_created?
   self.initiator.is_admin? if self.initiator.present?
  end
  
  def image_url
    #if initiator.present? && initiator.image.present?
    #  initiator.image.image.url(:icon)
    #else
    #  "/assets/no_user.png"
    #end
    "#{ENV['cloudfront']}/assets/deal_small.png"
  end
  
  def initiator_name
    initiator.present? ? initiator.full_name : ""
  end
  
  def assigned_user_name
    assigned_user.present? ? assigned_user.full_name : "Not Available"
  end
  
  def contacts_name  
      deals_contacts.map {|a| a.contactable.present? ? a.contactable.full_name : "Not Available"}.join(",")
  end
  
  def contacts_email  
      deals_contacts.map {|a| a.contactable.present? ? (a.contactable.email.present? ? a.contactable.email : "Not Available") : "Not Available"}.join(",")
  end
  
  def contacts_phone_no
      deals_contacts.map {|a| a.contactable.present? ? (a.contactable.phones.first.present? ? a.contactable.phones.first.phone_no : "Not Available") : "Not Available"}.join(",")
  end
  
  def created_by
    initiated_by
  end
  
  def priority_id
    priority_type_id
  end
  
  def deal_status_name
    status=""
    if self.deal_status.present?
      status=self.deal_status.name
      status = "New Deal" if self.deal_status.name == "Deal"
    end
    status
  end
  def compdesignation
    self.contact_info['comp_desg']
  end
  
  def contact_name
    self.contact_info['name']
  end
  
  def contact_email
    self.contact_info['email']
  end
  
  def contact_phone
    self.contact_info['phone']
  end
  
  def contact_type
    self.contact_info['type']
  end
  
  def contacts_id
    self.contact_info['id']
  end
  
  def contact_location
    self.contact_info['loc']
  end
  
  def deal_duration
    self.duration.split(",")[0] if self.duration
  end
  
  def deal_duration_type
    self.duration.split(",")[1] if self.duration
  end
  
  def contact_loc
    self.contact_info['loc']
  end
  #for leader dashboadr
  def self.find_avg_deal_close_ratio_status_won user_id, org_id, start_date, end_date
    ratio = 0
    t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deal_moves.created_at between '#{start_date}' and '#{end_date}' and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = #{org_id} and original_id in (4)) and (deals.assigned_to = #{user_id})")
     t.each do |row|
      ratio = row[0].to_f
    end
    return ratio
  end
  
 def self.find_avg_deal_ratio_status_won user_id, org_id, start_date, end_date
    ratio = 0
    t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg, min(datediff(deal_moves.created_at,deals.created_at)+1) as min_avg, max(datediff(deal_moves.created_at,deals.created_at)+1) as max_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deals.created_at between '#{start_date}' and '#{end_date}' and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = #{org_id} and original_id in (4)) and (deals.assigned_to = #{user_id})")
     result = []
     t.each do |row|
      result << row[0].to_f
      result << row[1]
      result << row[2]
    end
    return result
  end
  def associated_users
    ids=[]
    ids << self.assigned_to
    ids << self.created_by
    ids
  end

  def collect_company_designaion
   #.company_contact.present? && @contact.company_contact.name.present?
   if self.deals_contacts.first.contactable && self.deals_contacts.first.contactable.is_individual?
     if (self.deals_contacts.first.contactable.company_contact.present?) && (self.deals_contacts.first.contactable.company_contact.name.present?)
         designation = self.deals_contacts.first.contactable.position 
         company_name = self.deals_contacts.first.contactable.company_contact.name       
         data=""
         if designation.present?
          data += designation
         end
         if company_name.present?
           if data != ""
            data += ", "+company_name
           else
              data += company_name
           end
         end
         data
     end
   end
   
  
  end
  
  def self.active_multi_filter(params)
   
    query=""
    prio=false
    label_type=false
    if params[:label_type].present?
      label_type=true
      query += "`deal_labels`.`user_label_id`=#{params[:label_type]}"
    end
    
    if params[:cre_by] == true || params[:cre_by] == "true"
      if params[:cre_by_val].present? && (cre=params[:cre_by_val].split('|')).present? && (cre_ids=cre.join(','))
        query += "`deals`.`initiated_by` IN (#{cre_ids})"
      end
#    params[:cre_by].present? || params[:cre_by_val].present? || params[:asg_by].present? || params[:asg_by_val].present? || params[:loc].present? || params[:loc_val].present? || params[:priority].present? || params[:priority_val].present?
    end
    if params[:asg_by] == true || params[:asg_by] == "true"
      query += " and "if query.present?
      if params[:asg_by_val].present? && (asg=params[:asg_by_val].split('|')).present? && (asg_ids=asg.join(','))#&& (asg_ids = asg.map{|a| a.to_i})
        query += "`deals`.`assigned_to` IN (#{asg_ids})"
      end
    end
    if params[:loc] == true || params[:loc] == "true"
      query += " and "if query.present?
      if params[:loc_val].present? && (con=params[:loc_val].split('|')).present? && (coun_ids=con.join(','))
        query += "`deals`.`country_id` IN (#{coun_ids})"
      end
    end
    if params[:priority] == true || params[:priority] == "true"
      query += " and "if query.present?
      if params[:priority_val].present? && (prio=params[:priority_val].split('|')).present? && (prio_ids=prio.join(','))
        query += "`deals`.`priority_type_id` IN (#{prio_ids})"
      end
      prio = true
    end
    if params[:next] == true || params[:next] == "true"
      query += " and "if query.present?      
      #query1 += "tasks.task_type_id =#{params[:next_val]} and tasks.is_completed = 0"
      if params[:next_val].present? && (nex=params[:next_val].split('|')).present? && (next_ids=nex.join(','))
        query += "`deals`.`latest_task_type_id` IN (#{next_ids})"
      end
      nex=true
    end
    
    if params[:is_opportunity] == "true"
      query += " and "if query.present?      
      query += "`deals`.`is_opportunity`=true"
    end
    
    if params[:daterange] == "true"
      query += " and "if query.present?
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
      query += "`deals`.`created_at` BETWEEN '#{startdate}' AND '#{enddate}'"
    end
    
     if ((params[:dtrange_from] == true || params[:dtrange_from] == "true") && (params[:dtrange_to] == true || params[:dtrange_to] == "true"))
      query += " and "if query.present?
      frmdate = Date.parse(params[:dt_range_from]).strftime("%Y-%m-%d")
      todate = Date.parse(params[:dt_range_to]).strftime("%Y-%m-%d")
      query += "`deals`.`created_at` BETWEEN '#{frmdate}' AND '#{todate}'"
     end

    if params[:last_tch] == "true"
      query += " and "if query.present?
      if params[:last_touch] == "Last Week"
        last_d = (DateTime.now - 7.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Two Weeks"
        last_d = (DateTime.now - 14.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Three Weeks"
        last_d = (DateTime.now - 21.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Month"
        last_d = (DateTime.now - 1.month).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Three Months"
        last_d = (DateTime.now - 3.month).strftime("%Y-%m-%d")
      end
     query += "`deals`.`last_activity_date` < '#{last_d}'"
    end
    if params[:stage] == true || params[:stage] == "true"
      query += " and "if query.present?
      if params[:stage_val].present? && (stage=params[:stage_val].split('|')).present? && (stage_ids=stage.join(','))
        query += "`deals`.`deal_status_id` IN (#{stage_ids})"
      end
      stage = true
    end
    #if prio
     #joins(:priority_type).where(query).order("last_activity_date desc")
    #else
    if label_type
     joins(:deal_labels).where(query)
    else
     where(query).order("last_activity_date desc")
    end
    #end
  end
  
  
  def closed_by_name
    user=User.where(id: self.closed_by).first
    user.present? ? user.full_name : ""
  end

    def need_attention?(current_user)
      attention_required = false
    if created_at.in_time_zone(current_user.time_zone) + 24.hours < Time.zone.now
      attention_required = true
      if tasks.present?
        attention_required = false if (tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d")).count == 0)
      elsif attachments.present?
        attention_required = false if (attachments.last.created_at.in_time_zone(current_user.time_zone) + 24.hours > Time.zone.now)
      end
    end
    attention_required
  end
  
  
  def self.avg_time_close_deal user, org_id, start_date, end_date
    ratio = 0    
    unless (user.is_admin? || user.is_super_admin?)    
          t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deal_moves.created_at between '#{start_date}' and '#{end_date}' and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = #{org_id} and original_id in (4)) and (deals.assigned_to = #{user.id})")
     else
         t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deal_moves.created_at between '#{start_date}' and '#{end_date}' and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = #{org_id} and original_id in (4))")     
     end
     t.each do |row|
      ratio = row[0].to_f
    end
    return ratio
  end
  
end
