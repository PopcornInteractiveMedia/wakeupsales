class SubscribeBlogLog < ActiveRecord::Base
  attr_accessible :blog_content, :blog_title, :contact_email, :contact_id, :status, :error_message
end
