class Activity < ActiveRecord::Base

  attr_accessible :activity_type, :activity_id, :activity_user_id, :activity_status, :activity_desc, 
  :activity_date, :is_public, :organization_id, :source_id, :activity_by


  scope :by_range, lambda{ |start_date, end_date| where(:activity_date => start_date..end_date) }

  #has_many :users, :class_name=>"User" ,:foreign_key=>"activity_user_id"
  belongs_to :user, :class_name=>"User" ,:foreign_key=>"activity_user_id"
  has_many :deals, :class_name=>"Deal" ,:foreign_key=>"sorce_id"
  has_many :activities_contacts
  has_many :sent_email_opens


end
