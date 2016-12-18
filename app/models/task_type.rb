class TaskType < ActiveRecord::Base
  attr_accessible :name, :organization_id
  
  belongs_to :organization
  has_many :task_types
  
    TASK_COLORS={"Appointment"=>"#FAA732", "Billing"=> "#999966", "Call" => "#49AFCD", "Documentation" => "#3399FF", "Email" => "#0099CC", "Follow-up" => "#DA4F49", "Meeting" => "#5F04B4", "None" => "#A4A4A4", "Quote" => "#763532", "Thank-you" => "#5BB75B"}
end
