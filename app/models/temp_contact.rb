class TempContact < ActiveRecord::Base
  attr_accessible :import_by,:domain,:email,  :first_name, :last_name, :name, :birthday, :city, :country,  :gender,:address_1, :address_2, :phone_number, :postcode, :profile_picture, :region, :relation, :updated, :company_name, :website
end
