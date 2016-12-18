class Image < ActiveRecord::Base
  belongs_to :imagable , :polymorphic=> true
  belongs_to :organization
  belongs_to :contact
  belongs_to :IndividualContact
  belongs_to :CompanyContact
  
  attr_accessible :imagable_id, :imagable_type, :image_content_type, :image_file_name, 
               :image_file_size, :image_updated_at, :organization, :imagable, :image
  
  has_attached_file :image,
                  :storage => :s3,
                  :s3_credentials => S3_CREDENTIALS,
                  :styles => { :icon => "50x50>", :thumb => "75x75>", :small => "150x150>", :medium => "200x200>" },
                  :convert_options => {:all=>"-strip"},
                  :path => "images/:id/:styles_:basename.:extension",
                  :url => "images/:id/:styles_:basename.:extension",
                  :s3_headers => {'Cache-Control' => 'max-age=315576000', 'Expires' => 1.years.from_now.httpdate }
  
end
