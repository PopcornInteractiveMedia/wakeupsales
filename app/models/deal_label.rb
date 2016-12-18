class DealLabel < ActiveRecord::Base
  belongs_to :organization
  belongs_to :deal
  belongs_to :user_label
  # attr_accessible :title, :body
  attr_accessible :deal_id,:user_label_id,:organization
end
