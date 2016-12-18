class TempTable < ActiveRecord::Base
  attr_accessible :address, :company_name, :email, :name, :phone, :ref_site, :title, :web_site, :city, :state, :zipcode, :country, :user_id
end
