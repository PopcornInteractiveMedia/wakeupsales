module DealsHelper

 def get_deal_activity_stream_new deal_id
     deal = Deal.find(deal_id)
     activities = deal.activities.where("organization_id = ?", current_user.organization.id).order("activity_date desc")

 end
 

 
 def get_deal_activity_stream deal_id
   activities = []
   deal = Deal.includes([:tasks,:deal_moves]).find(deal_id)
   activities << deal
   activities << deal.tasks
   #activities << deal.attachments.includes([:user])
   activities << deal.deal_moves
   
   deal.deal_moves.includes([:attachment]).each do |deal_move|
    activities << deal_move.attachment if deal_move.attachment.present?
   end
   activities = activities.flatten.sort! { |x,y| y.created_at <=> x.created_at}
 end
 
 
 def last_activity(deal_id)
  activity=get_deal_activity_stream(deal_id).first
  last_updated_by=""
  if(activity.class.name == "Deal")
    user=User.where("id=?",activity.initiated_by).first
    last_updated_by="me" if user.present? && user.id==current_user.id
    last_updated_by = activity.initiator.full_name if activity.present? && activity.initiator.present? 
  elsif(activity.class.name == "DealMove")
    last_updated_by=(activity.user_id) == current_user.id ? "me" : (activity.user.present? ? activity.user.full_name : "")
  else
    user=User.where("id=?",activity.created_by).first
    last_updated_by="me" if user.present? && user.id==current_user.id
    last_updated_by = activity.user.full_name if activity.user.present?
  end
  return get_activity_timing(activity), last_updated_by
 end

def last_activity_show(deal_id)
  activity=get_deal_activity_stream(deal_id).first
  last_updated_by=""
  if(activity.class.name == "Deal")
    user=User.where("id=?",activity.initiated_by).first
    last_updated_by="me" if user.present? && user.id==current_user.id
    last_updated_by = activity.initiator.full_name if activity.present? && activity.initiator.present? 
  elsif(activity.class.name == "DealMove")
    last_updated_by=(activity.user_id) == current_user.id ? "me" : (activity.user.present? ? activity.user.full_name : "")
  else
    user=User.where("id=?",activity.created_by).first
    last_updated_by="me" if user.present? && user.id==current_user.id
    last_updated_by = activity.user.full_name if activity.user.present?
  end
  return get_activity_timing_show(activity), last_updated_by
 end
 
 def last_activity_show_new(deal_id)
    deal = Deal.includes(:activities).find(deal_id) 
    activity= deal.activities.where("organization_id = ?", current_user.organization.id).order("activity_date desc").first
    if activity.present?
       user=User.where("id=?",activity.activity_user_id).first
       if user.present? 
         last_updated_by=(activity.activity_user_id) == current_user.id ? "me" : (activity.user.present? ? activity.user.full_name : "")    
    
       end
     return distance_of_time_in_words_to_now(activity.activity_date), last_updated_by
    end
 
 end
 
 def get_activity_timing(activity)
  activity.created_at.strftime("%b %d, %Y @ %I:%M %p")
 end
 
def get_activity_timing_show(activity)
  distance_of_time_in_words_to_now activity.created_at
 end
 
 def get_file_type_img(type)
    data = type.scan(/\.\w+$/)
   case data[0]
     when ".jpg" 
       return "/assets/jpgimg.png"
     when  '.jpeg'
       return "/assets/jpgimg.png"  
     when ".doc" 
       return "/assets/docimg.png"
	 when ".DOC" 
       return "/assets/docimg.png"
     when  ".docx"
       return "/assets/docimg.png"  
     when ".xls" 
       return "/assets/xlsimg.png"
     when ".xlsx"
       return "/assets/xlsimg.png"  
     when ".ppt" 
       return "/assets/pptimg.png"   
     when  ".pptx"
       return "/assets/pptimg.png"   
     when ".pdf"
       return "/assets/pdfimg.png"
     when ".png"
       return "/assets/pngimg.png"
     when ".txt"
       return "/assets/txtimg.png"
	 when ".html"
       return "/assets/htmlimg.png"
	 when ".htm"
       return "/assets/htmlimg.png"	
	 when ".mp4"
       return "/assets/mp4img.png"	   
	 when ".mp3"
       return "/assets/mp3img.png"	   
   else
     return "/assets/fileimg.png"
   end
 end
 def last_activity_for_deal_json(deal,user)
  activity=get_deal_activity_stream(deal).first
  current_user = user
  title = ""
  last_updated_by=""
#  if(activity.class.name == "Task")
#    
#    activity.title
#    last_updated_by=(user=User.find(activity.created_by)).id == current_user.id ? "me" : activity.user.full_name
#  elsif(activity.class.name == "Note")
#    activity.notes
#    last_updated_by=(user=User.find(activity.created_by).id) == current_user.id ? "me" : activity.user.full_name
  if(activity.class.name == "Deal")

#     deal.title
    last_updated_by=""
    if activity.initiated_by.present?
      user=User.where("id=?",activity.initiated_by).first
      if user.present? && user.id == current_user.id
         last_updated_by = "me"


      elsif activity.initiator.present?
        activity.initiator.full_name
      end
    end
    #(user_name=User.find(activity.initiated_by).id) == current_user.id ? "me" : activity.initiator.full_name
#  elsif(activity.class.name == "Contact")
#    if activity.contact_type == "Company"
#        name = "#{activity.name}" + ", " + "#{activity.full_name}"
#      else
#        name = "#{activity.full_name}"
#      end
#    (user_name=User.find(contact.created_by).id) == current_user.id ? "me" : contact.initiator.full_name
  elsif(activity.class.name == "DealMove")
#     activity.deal.title

    last_updated_by=(activity.user_id) == current_user.id ? "me" : (activity.user.present? ? activity.user.full_name : "")
  else

    
    last_updated_by=""
    if activity.created_by.present?
      user=User.where("id=?",activity.created_by).first
      if user.present? && user.id == current_user.id
         last_updated_by = "me"


      elsif activity.user.present?
        activity.user.full_name
      end
    end
  #last_updated_by=(user=User.find(activity.created_by)).id == current_user.id ? "me" : activity.user.full_name
  end
  return get_activity_timing(activity), last_updated_by, get_activity_timing_show(activity)
 end

 def last_activity_for_deal_json_new(deal,user)
#  deal = Deal.includes(:activities).find(deal) #.order("activity_date desc").first
  #activity = Activity.select("activity_date").where(:source_id => deal).last
  #activity=get_deal_activity_stream_new(deal).first
  # activity= deal.activities.where("organization_id = ?", user.organization.id).last
  # if activity.present?
    # distance_of_time_in_words_to_now activity.activity_date
  # end
  if deal.last_activity_date.present?
   distance_of_time_in_words_to_now deal.last_activity_date 
  end
 end

  def get_current_quarter(date)    
    quarters = [1, 2, 3, 4]
    quarters[(date.month - 1) / 3]     
  end
 
  def calculate_win_percentage total, won
   result = ((((won.to_f / total.to_f)) * 100)/3).to_f
   result = result.nan? ? 0 : result.round(2)
   
  end
end
