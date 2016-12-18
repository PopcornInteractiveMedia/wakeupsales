class EmailNotification < ActiveRecord::Base
  belongs_to :user
  attr_accessible :deal_assign, :donot_send, :due_task, :task_assign, :user_id
end
