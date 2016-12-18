class TempImage < ActiveRecord::Base
  belongs_to :user
  attr_accessible :avatar, :user_id, :crop_x, :crop_y, :crop_w, :crop_h
               
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
#  after_update :reprocess_image, :if => :cropping?
  
  has_attached_file :avatar,
                  :storage => :s3,
                  :s3_credentials => S3_CREDENTIALS,
                  :styles => { :original => "500x500>"},
                  :convert_options => {:all=>"-strip"},
                  :path => "TempImage/:id/:styles_:basename.:extension",
                  :url => "TempImage/:id/:styles_:basename.:extension",
                  :s3_headers => {'Cache-Control' => 'max-age=315576000', 'Expires' => 1.years.from_now.httpdate },
				  :processors => [:cropper]
  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  def avatar_geometry(style = :original)
     @geometry ||= {}
     imgpath=self.avatar.url(style)
     a=imgpath.split('?')
     puts a 
    attch= do_download_remote_image
    #image_data = Net::HTTP.get_response(URI.parse(attachment.url(style))).body
    image_data = Net::HTTP.get_response(URI.parse(a[0])).body
    orig_img = Magick::ImageList.new
    orig_img.from_blob(image_data)
    tmp_img = Tempfile.new(self.attachment_file_name)
    tmp_img.binmode
    tmp_img.write(orig_img.to_blob)
    tmp_img.close
     @geometry[style] ||= Paperclip::Geometry.from_file(tmp_img)
     #@geometry[style] ||= Paperclip::Geometry.from_file(attch).path
    #@geometry[style] ||= Paperclip::Geometry.from_file(Paperclip.io_adapters.for(a[0]).path)
    #@geometry[style] ||= Paperclip::Geometry.from_file(Paperclip.io_adapters.for(attachment).path)
  #@geometry[style] ||= Paperclip::Geometry.from_file(attachment.url(style))

  end
  def do_download_remote_image
    io = open(URI.parse(self.attachment.path(style),attachment_file_name))
    def io.original_filename; attachment.path.split('/').last; end
    io.original_filename.blank? ? 'attachment_file_name.jpg' : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  def cropping?
    puts "cropping? >>>>>>>>>>>>>>>>>"
    p !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def avatar_geometry(style = :original)
    @geometry ||= {}
    avatar_path = (avatar.options[:storage] == :s3) ? avatar.url(style) : avatar.path(style)
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar_path)
  end
  def crop
  if(!self.crop_x.nil? && !self.crop_y.nil? && !self.crop_w.nil? && !self.crop_h.nil?)
      reprocess_image
    end
  end
  
  
  def reprocess_image
    puts "reprocess_image >>>>>>>>>>>>>>>>>>>>"
    avatar.reprocess!
#    image.assign(image)
#    image.save
  end
end
