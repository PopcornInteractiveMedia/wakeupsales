module Paperclip  
 class Cropper < Thumbnail  
   def transformation_command  
     if crop_command
       original_command = super
       if original_command.include?('-crop')
         original_command.delete_at(super.index('-crop') + 1)
         original_command.delete_at(super.index('-crop'))
       end
       crop_command + original_command
     else  
       super  
     end  
   end  
 
   def crop_command  
     target = @attachment.instance  
     if target.cropping?
       ["-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
     end  
   end  
 end  
end

# module Paperclip
  # class Cropper < Thumbnail
    # def transformation_command
      # if crop_command
        # puts "CROP THIS IMAGE >>>>>>>>>>>>>"
        # crop_command + super.join(' ').sub(/ -crop \S+/, '').split(' ') # super returns an array like this: ["-resize", "100x", "-crop", "100x100+0+0", "+repage"]
      # else
        # puts "NO CROP >>>>>>>>>>>>>"
        # super
      # end
    # end
# 
    # def crop_command
      # target = @attachment.instance
      # if target.cropping?
        # ["-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
      # end
    # end
  # end
# end
# 
