class Source < ActiveRecord::Base
  belongs_to :organization
  has_many :deal_sources,:dependent => :destroy
  attr_accessible :name, :organization
  
  validates :name, :uniqueness => {:scope => :organization_id}
  
  def self.source_list(organization)
    select("id, name, organization_id").where("organization_id=?", organization)
  end
  
  def self.get_name(source_id)
    select("name").where("id=?", source_id).first.name
  end
end
