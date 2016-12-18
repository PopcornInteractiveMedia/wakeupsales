module HomeHelper

 ##Activites as per organization includes deals,contacts,tasks and notes
 def get_organization_activity_stream org_id
   activities = []
   org = Organization.find org_id
   activities << org.deals
   activities << org.deal_moves
   activities << org.contacts
   activities << org.tasks
   activities << org.attachments
   activities = activities.flatten.sort! { |x,y| y.created_at <=> x.created_at } 
 end

def activity_stream org_id, page =1, per_page=20
    #activities = Organization.find_by_sql("select id,'Organization' as name,created_at from organizations where id = "+org_id.to_s+"
    #UNION ALL
    #select id,'Deal' as name,created_at from deals where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'CompanyContact' as name,created_at from  company_contacts where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'IndividualContact' as name,created_at from individual_contacts where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'DealMove' as name,created_at from deal_moves where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'Task' as name,created_at from tasks where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'Note' as name,created_at from notes where organization_id = "+org_id.to_s+"
    #order by created_at desc limit " + per_page.to_s + " offset " + ((page-1)*per_page).to_s)
    
    
    activities = current_user.organization.activities.limit(per_page.to_s).offset(((page-1)*per_page).to_s).order("activity_date desc") 
  
   
    
  end
  
  
  def calculate_ratio_monthwise prev, current, prev_week, current_week
      avg_prev = (prev.to_f / prev_week.to_f)
      avg_cur = (current.to_f / current_week.to_f)
      if avg_prev!= 0
        result = ( avg_cur - avg_prev ) * 100 / avg_prev
      else
        result = ( avg_cur - avg_prev ) * 100 
      end
      result = result.nan? ? 0 : result
  end  
  
  def calculate_ratio_weekwise prev_week, current_week
    if prev_week != 0
      ( current_week.to_f - prev_week.to_f ) * 100 / prev_week.to_f
    else
      ( current_week.to_f - prev_week.to_f ) * 100
    end
  end

  def build_contact_us_info (email, name, comment, phone=nil,is_remote=false)
      contact = ContactUs.where(:email => email).first
      if contact.nil? || contact.blank?
           a = ContactUs.create :email => email , :is_remote => is_remote
           ContactUsInfo.create :name => name, :comment => comment, :phone => phone, :contact_us => a
      else
          ContactUsInfo.create :name => name, :comment => comment, :phone => phone, :contact_us => contact
      end
  end




end
