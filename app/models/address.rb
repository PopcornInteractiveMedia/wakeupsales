class Address < ActiveRecord::Base
  belongs_to :organization
  belongs_to :country ,:foreign_key=>"country_id"
  belongs_to :addressable , :polymorphic=> true
  
  
  attr_accessible :address, :address_type, :addressable_id, :addressable_type, :organization_id, :city, :state, :zipcode,:country_id,:organization, :addressable
end
