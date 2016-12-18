class TaskPriorityType < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :original_id
end
