class Phone < ActiveRecord::Base
  belongs_to :organization
  belongs_to :phoneble , :polymorphic=> true
  attr_accessible :extension, :phone_no, :phone_type, :phoneble_id, :phoneble_type,
    :organization,:organization_id, :phoneble
  
  
  scope :by_phone_type, lambda{|type| where("phone_type = ? ", type)}
  
  
end
