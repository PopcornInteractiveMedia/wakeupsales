
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable,:database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable,:confirmable, :omniauthable, :omniauth_providers => [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :remember_me,:admin_type, :time_zone, :task_date,
                  :first_name, :last_name, :work_phone, :role_id, :profile_image, :confirmed_at, :confirmation_token, :is_beta_user,:priority_label,:digest_mail_date, :organization_id
  # attr_accessible :title, :body
  belongs_to :organization
  belongs_to :role
  has_one :user_preference, :dependent => :destroy
  has_one :deal_setting, :dependent => :destroy
  has_one :user_role, :dependent => :destroy
  has_one :phone, :as => :phoneble, :dependent => :destroy
  has_one :image, :as => :imagable, :dependent => :destroy
  has_one :email_notification, :dependent => :destroy
  has_one :attention_deal, :dependent => :destroy
  has_one  :widget, :dependent => :destroy
  has_many :deals, :class_name=>"Deal", :dependent => :nullify,:foreign_key=>"assigned_to"
  has_many :user_labels,:class_name=>"UserLabel", :dependent => :destroy
  has_many :attachments, :class_name=>"Note", :dependent => :nullify,:foreign_key=>"created_by"
  has_many :activities, :dependent => :destroy,:foreign_key=>"activity_user_id"
  attr_accessor :organization_name,:organization_website,:organization_size, :work_phone, :profile_image, :is_beta_user
  after_save :save_other_information
  after_create :create_default_data
  
  scope :by_active, lambda{where("is_active = ?", true)}
  
  def create_default_data
     Widget.create :organization_id => self.organization.id, :user => self
     UserPreference.create :organization_id => self.organization.id, :user => self
  end
  # def name
    # if first_name.present? && last_name.present?
      # first_name+" "+last_name
    # else
      # first_name
    # end
  # end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      user.token = access_token.credentials.token
      user.save!
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        registered_user.provider = access_token.provider
        registered_user.uid = access_token.uid
        registered_user.token = access_token.credentials.token
        registered_user.save!
        return registered_user
      else
        user = User.create(first_name: data["name"],
          provider:access_token.provider,
          email: data["email"],
          uid: access_token.uid ,
          token: access_token.credentials.token,
          password: Devise.friendly_token[0,20],
          admin_type: 1,
          confirmation_token: nil,
          confirmed_at: Time.now,     
        )
      end
   end
end
  
  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    Thread.current[:user] = user
  end
  
  def all_deals
    ## disabled public deals view by normal user
    #return Deal.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",self.id,self.id,self.organization.id).order("deals.created_at DESC")  
    if(self.is_admin? or self.is_super_admin?)
      return Deal.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",self.id,self.id,self.organization.id).order("deals.created_at DESC")  
    else
      return Deal.where("(assigned_to = ? or initiated_by= ?) and ( deals.organization_id = ?)",self.id,self.id,self.organization.id).order("deals.created_at DESC")   
    end
  end
  
  def my_deals
    return Deal.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?",self.id,self.id,self.organization.id).order("deals.created_at DESC")    
  end
 
  def my_created_deals
    return Deal.where("initiated_by= ? and deals.organization_id = ?",self.id,self.organization.id).order("deals.created_at DESC")    
  end
  
  #Using for last deal close for non-admin user
  def all_deals_dashboard
    #return Deal.where("assigned_to = ? or initiated_by= ?",self.id,self.id)
    return Deal.where("deals.assigned_to = ? or deals.initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",self.id,self.id,self.organization.id)    
  end
  
  def my_deals_dashboard
    #return Deal.where("assigned_to = ? or initiated_by= ?",self.id,self.id)
    return Deal.where("(deals.assigned_to = ? or deals.initiated_by= ?) and deals.organization_id = ?",self.id,self.id,self.organization.id)    
  end 
  
  def all_assigned_or_created_deals
    #return Deal.where("assigned_to = ? or initiated_by= ?",self.id,self.id)
    return Deal.where("(deals.assigned_to = ? or deals.initiated_by= ?) and deals.organization_id = ?",self.id,self.id, self.organization_id).order("deals.created_at DESC")    
  end
  
  def all_assigned_deal
    return Deal.where("deals.assigned_to = ? and deals.organization_id = ? ",self.id, self.organization_id)
  end
  
  def all_tasks
    return Task.where("(tasks.created_by = ? or tasks.assigned_to = ?)  and organization_id = ?",self.id,self.id, self.organization_id)
  end
  
  
  def all_tasks_assigned
    return Task.where("tasks.assigned_to = ?  and tasks.organization_id = ?",self.id, self.organization_id)
  end
  
  
  def save_other_information   
    if (self.image.nil?) && self.profile_image.present?
      Image.create(:organization => self.organization,:image=> self.profile_image, :imagable=> self)
    elsif self.image.present? && self.profile_image.present?
      self.image.update_attributes(:image=> self.profile_image)
    end
    if !(self.phone.present?) && self.work_phone.present?
      Phone.create(:organization => self.organization,:phone_no=> self.work_phone, :phoneble=> self)
    elsif self.phone.present? && self.work_phone.present?
      self.phone.update_attributes(:phone_no=> self.work_phone)
    end
    
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  # def name
    # return first_name + (!last_name.nil? && !last_name.blank? ? " " + last_name : "")
  # end
  def is_super_admin?
    if admin_type == 1
      return true
    else
      return false
    end
  end
  def is_admin?
    admin_type == 2 || admin_type ==1
  end
  
  def is_siteadmin?
    admin_type == 0
  end

  def after_password_reset; end
  
end
