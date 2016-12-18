class Industry < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name,:organization
  has_many :deal_industries,:dependent => :destroy
  
  validates :name, :uniqueness => {:scope => :organization_id}
  
  def self.industry_list(organization)
    select("id, name, organization_id").where("organization_id=?", organization)
  end

  def self.get_name(source_id)
    select("name").where("id=?", source_id).first.name
  end
end
