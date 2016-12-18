module ContactsHelper
  def save_contact_to_address contact, country
    addr=Address.new
    addr.organization = current_user.organization
    addr.country_id = country
    addr.addressable = contact
    addr.save
  end

  def save_contact_to_phone contact, work_phone, extension, type
    phone =Phone.new
    phone.organization = current_user.organization
    phone.phone_no = work_phone
    phone.extension = extension
    phone.phone_type = type
    phone.phoneble = contact
    phone.save
  end

  def get_contact_activity_stream contact_type, contact_id
    #activities = Contact.find(contact_id).select("id,'Contact' as _type ").joins(:deals).merge(contact.deals.select("id,'Deal' as _type"))
    activities = []
    contact = contact_type == "individual" ? IndividualContact.where("id=?", contact_id).first : CompanyContact.where("id=?", contact_id).first


    if contact.present?
      #activities << contact
      #activities << contact.deals
      activities << contact.deals_contacts
      activities << contact.attachments
      activities << contact.tasks
      activities = activities.flatten.sort! { |x, y| y.created_at <=> x.created_at }
    end
    activities
  end

  def get_contact_activities contact_type, contact_id
    ##activities = Contact.find(contact_id).select("id,'Contact' as _type ").joins(:deals).merge(contact.deals.select("id,'Deal' as _type"))
    #activity_data = []
    #if contact_type.present?
    # contact = contact_type.constantize.where("id=?",contact_id).first
    # puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    # p contact
    #if contact.present? && contact.activities.present?
    #activity_data = contact.activities.order("activity_date desc")
    # end
    #end
    #activity_data
    activities = []
    if contact_type == "CompanyContact"
      c = CompanyContact.find contact_id
    elsif contact_type == "IndividualContact"
      c = IndividualContact.find contact_id
    end
    c.activities_contacts.order("created_at desc").each do |a|
      activities << a.activity
    end
    activities
  end


  def contact_last_activity(contact_id)
    activity=get_contact_activity_stream(contact_id).first
    last_updated_by=""
    if activity.present?
      if (activity.class.name == "Deal")
        user = User.where("id=?", activity.initiated_by).first
        if user.present?
          last_updated_by=(user_name=User.find(activity.initiated_by).id) == current_user.id ? "me" : activity.initiator.first_name
        end
      else
        if user.present?
          last_updated_by=(user=User.find(activity.created_by)).id == current_user.id ? "me" : activity.user.first_name
        end
      end
    end
    return get_contact_activity_timing(activity), last_updated_by
  end

  def contact_last_activity_show(contact_id, type)
    activity=get_contact_activity_stream(type, contact_id).first
    last_updated_by=""
    if (activity.class.name == "Deal")
      user=User.where("id=?", activity.initiated_by).first
      last_updated_by = activity.initiator.full_name if activity.present? && activity.initiator.present?
      last_updated_by="me" if user.present? && user.id==current_user.id

    elsif (activity.class.name == "DealMove")
      last_updated_by=(activity.user_id) == current_user.id ? "me" : (activity.user.present? ? activity.user.full_name : "")
    elsif ((activity.class.name == "DealsContact") && activity.deal.present?)
      puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

      user=User.where("id=?", activity.deal.initiated_by).first
      last_updated_by = user.full_name if user.present? && activity.contactable.present?

      last_updated_by="me" if user.present? && user.id==current_user.id
    elsif (activity.class.name == "Task")
      user=User.where("id=?", activity.created_by).first
      last_updated_by = user.full_name if user.present?
      last_updated_by="me" if user.present? && user.id==current_user.id
    else
      if (activity.class.name != "DealsContact")
        user=User.where("id=?", activity.created_by).first if activity.present? && !activity.created_by.nil?
        last_updated_by = activity.user.full_name if activity.present? && activity.user.present?
        last_updated_by="me" if user.present? && user.id==current_user.id

      end
    end
    return get_contact_activity_timing(activity), last_updated_by
  end


  def show_contact_last_activity(contact_id, type)
    activity=get_contact_activity_stream(type, contact_id).first
    last_updated_by=""
    if (activity.class.name == "Deal")
      user=User.where("id=?", activity.initiated_by).first
      last_updated_by = activity.initiator.full_name if activity.present? && activity.initiator.present?

    elsif (activity.class.name == "DealMove")
      last_updated_by= activity.user.present? ? activity.user.full_name : ""

    elsif ((activity.class.name == "DealsContact") && activity.deal.present?)
      user=User.where("id=?", activity.deal.initiated_by).first
      last_updated_by = user.full_name if user.present? && activity.contactable.present?

    elsif (activity.class.name == "Task")
      user=User.where("id=?", activity.created_by).first
      last_updated_by = user.full_name if user.present?

    else
      if (activity.class.name != "DealsContact")
        user=User.where("id=?", activity.created_by).first if activity.present? && !activity.created_by.nil?
        last_updated_by = activity.user.full_name if activity.present? && activity.user.present?

      end
    end
    return get_contact_activity_timing(activity), last_updated_by
  end

  def get_contact_activity_timing(activity)
    distance_of_time_in_words_to_now activity.created_at if activity.present?
  end

  def save_sent_email
    p params
    deal_conversation = DealConversation.new({
                                                 deal_id: params[:mailer_id],
                                                 user_id: current_user.id,
                                                 organization_id: current_user.organization.id,
                                                 subject: params[:subject],
                                                 # cc: params[:cc],
                                                 # bcc: params[:bcc],
                                                 message: params[:message]
                                             })
    if params[:attachment].present?
      deal_conversation.deal_attachments.build({attachment: params[:attachment], organization_id: current_user.organization.id})
    end
    deal_conversation.save
  end

end
