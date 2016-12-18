class ReportABug < ActiveRecord::Base
  attr_accessible :bug_status, :bug_type, :description, :email, :ip_address, :country
  acts_as_commentable
end
