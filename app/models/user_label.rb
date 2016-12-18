class UserLabel < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :deal_labels, :dependent => :destroy
  attr_accessible :color, :name,:organization,:user
end
