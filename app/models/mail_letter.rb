class MailLetter < ActiveRecord::Base
  belongs_to :organization
  belongs_to :mailable,:polymorphic=>true
  belongs_to :user , :class_name=> "User", :foreign_key => :mail_by
  serialize :contact_info, JSON
  attr_accessible :description, :mail_bcc, :mail_by, :mail_cc, :mailable_id, :mailable_type, :mailto, :subject,:organization,:organization_id,:mailable,:contact_info
  
end
