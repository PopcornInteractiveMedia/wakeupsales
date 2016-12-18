class NoteAttachment < ActiveRecord::Base
   attr_accessible :note_id, :attachment,:attachment_file_name,:attachment_content_type, :attachment_file_size, :attachment_updated_at
   
   belongs_to :note , :class_name=>"Note", :foreign_key => "note_id"
   
   has_attached_file :attachment,
                  :storage => :s3,
                  :s3_credentials => S3_CREDENTIALS,
                  :path => "notes/:id/:basename.:extension",
                  :url => "notes/:id/:basename.:extension"
                  
  #validates_attachment_content_type :attachment, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif","application/pdf", "application/xlsx", "application/xls", "application/doc", "application/docx", "application/ppt", "application/pptx","audio/mp3","audio/mpeg","audio/mpeg3","audio/x-mpeg-3"]
  #validates_attachment_content_type :attachment, :content_type => ["image/*","application/*","audio/*","video/*"]
  
end
