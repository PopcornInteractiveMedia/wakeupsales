class ContactUsInfo < ActiveRecord::Base
  belongs_to :contact_us
  attr_accessible :comment, :name, :phone, :contact_us
end
