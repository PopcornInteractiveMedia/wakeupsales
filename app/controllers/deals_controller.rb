class DealsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  include ApplicationHelper #FIXME AMT
  include ContactsHelper
  include DealsHelper
  include HotLeadAssignment
  
  #caches_action :show
  #cache_sweeper :cache_sweeper
   skip_before_filter :authenticate_user!, :only => [:accept_assign_deal,:deny_assign_deal]
  
  def index
    #@new_deals = new_deals_count()
    #home = HomeController.new
    # @new_deals = get_deal_status_count([1]).count
    puts "coming here"
    #@total_new_deals=@new_deals
    @filter_msg=nil
    associated_by=nil
    if params[:assigned_to].present?
      user = params[:assigned_to] == "me" ? @current_user : User.where(" organization_id=? AND id=?", @current_organization.id, params[:assigned_to]).first
      associated_by="assigned to"
    elsif params[:created_by].present?
      user = User.where(" organization_id=? AND id=?", @current_organization.id, params[:created_by]).first
      associated_by="created by"
    end
   
    if user.present?
        name = (user.id == current_user.id) ? "me" : user.full_name
        new_deal_condition = get_deal_status_count([1,2,3,4,5,6], user, associated_by)
        new_deal_count_condition =  get_deal_status_count([1])
        count_total = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(new_deal_count_condition).where("is_remote=0 and deal_statuses.original_id IN (?) and deal_statuses.is_active=? ", [1], true).count
        @new_deals =  Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(new_deal_condition).where("is_remote=0 and deal_statuses.original_id IN (?) ", [1]).count
        user_condition = get_deal_index_status_count([1,2,3,4,5,6], user, associated_by)
        @total_new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(user_condition).where("is_remote=0 and deal_statuses.original_id IN (?) and deal_statuses.is_active =?", [1],true).count
#      @new_deals = get_deal_status_count([1], user, associated_by).count
      unless (params[:q].present? && params[:y].present?)
         @filter_msg=""
      end
    end
    count_condition=get_deal_status_count([1,2,3,4,5,6])
    #@working_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("is_remote=0 and deal_statuses.original_id IN (?) AND is_current=? ", [1,2,3,4,5,6], true).count
   # @qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("is_remote=0 and deal_statuses.original_id IN (?)", [2]).count
   # @won_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("is_remote=0 and deal_statuses.original_id IN (?)", [4]).count
   # @lost_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("is_remote=0 and deal_statuses.original_id IN (?)", [5]).count
   # @not_qualify_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("is_remote=0 and deal_statuses.original_id IN (?)", [3]).count
   # @junk_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("is_remote=0 and deal_statuses.original_id IN (?)", [6]).count
   # @un_assigned_deals = Deal.select("deals.id").where(count_condition).where("is_remote=? and organization_id=? and is_active =1", 1, @current_organization.id ).count
    
    respond_to do |format|
      format.html
      format.json { render json: DealsDatatable.new(view_context) }
    end
  end
  def get_inactive_deals
    render :partial=> "deals/attention_deal_list"
  end
  def get_incoming_deals
    render :partial=> "deals/deal_incoming"
  end
  def get_working_on_deals
    render :partial=> "deals/deal_working"
  end
  def get_won_deals
    render :partial=> "deals/deal_won"
  end
  def get_lost_deals
    render :partial=> "deals/deal_lost"
  end
  def get_qualify_deals
    render :partial=> "deals/deal_qualify"
  end
  def get_not_qualify_deals
    render :partial=> "deals/deal_not_qualify"
  end
  def get_junk_deals
    render :partial=> "deals/deal_junk"
  end
  def get_un_assigned_deals
    render :partial=> "deals/deal_un_assigned"
  end
  def get_other_deals
    puts "dddddddddddddddddddddddddddddddddddddd"
    params[:dtype] = params[:dtype].present? ? params[:dtype] : "all"
    puts "coming to other deal"
    render :partial=> "deals/deal_other"
  end
  
 def show  

    query_condition=[]
    query_condition.where("deals.id = ? and deals.organization_id=?", params[:id],  @current_organization.id)
    unless @current_user.is_admin? || @current_user.is_super_admin?
       query_condition.where("(is_public=? OR (deals.assigned_to=? OR deals.initiated_by=?))", true, @current_user.id, @current_user.id) 
    end 
    
    unless(@deal=Deal.includes( :priority_type,:deal_source,:assigned_user,:deal_source,:deal_status,:initiator).where(query_condition).first).present?
     flash[:alert]="It seems you don't have sufficient privilege to access this item or something went wrong with your account permissions.<br/> Please contact Admin to get this fixed." 
     redirect_to leads_path
    
    end

  end
  
  def deal_contacts_info
#title
#amount
#priority
#created_at
#deal status name
#tags
#assigned user
#initiator_name
    puts "---------------"
#    p read_fragment("Deal-9459-Detail-Contact-Information").present?
    @deal_contacts=DealsContact.where("organization_id=? AND deal_id=?",@current_user.organization_id, params[:id])
    render partial: "deal_contacts_info"
  end
  
  
  def new
     @cat = @@category
  end
  
  def create
     contact = nil
      if !params[:deal][:contact_id].present?
        ic= IndividualContact.new
        ic.organization_id=current_user.organization_id
        ic.first_name = params[:deal][:first_name] ? params[:deal][:first_name] : params[:hidden_first_name]
        ic.email = params[:deal][:email]
        ic.country = params[:deal][:country]
        ic.work_phone = params[:deal][:work_phone]
        #ic.extension = params[:extension_deal_popup]
        ic.created_by = current_user.id
          if ic.save
            if(!params[:deal][:country].nil? && !params[:deal][:country].blank?)
              #save_contact_to_address ic,params[:deal][:country]
            end
            if(!params[:deal][:work_phone].nil? && !params[:deal][:work_phone].blank?)
              #save_contact_to_phone ic,params[:deal][:work_phone],params[:extension_deal_popup], "work"
            end
            contact = ic
          else
            contact = nil
            alert_msg=""
            msgs=ic.errors.messages
            msgs.keys.each_with_index do |m,i|
              alert_msg=m.to_s.camelcase+" "+msgs[m].first
              alert_msg += "<br />" if i > 0
            end
          end
      elsif params[:deal][:contact_id].present? && params[:company_type].present?
        contact = params[:company_type].constantize.find params[:deal][:contact_id]
        individual_contact={}
        individual_contact[:work_phone] = params[:deal][:work_phone] if params[:deal][:work_phone].present?
        individual_contact[:mobile_number] = contact.phones.by_phone_type("mobile").first.phone_no if contact.phones.present? && contact.phones.by_phone_type("mobile").present?
		if contact.address.present?
        individual_contact[:street]= contact.address.address if contact.address.address.present?
        individual_contact[:city]= contact.address.city if contact.address.city.present?
        individual_contact[:state]= contact.address.state if contact.address.state.present?
        individual_contact[:zip_code]= contact.address.zipcode if contact.address.zipcode.present?
		end
        individual_contact[:email] = params[:deal][:email] if params[:deal][:email].present?
        individual_contact[:country] = params[:deal][:country] if params[:deal][:country].present?
        contact.update_attributes(individual_contact)
#        contact = Contact.find params[:deal][:contact_id]
      end
      if contact.present?
        deal = Deal.new
        deal.organization = current_user.organization
        deal.title=params[:deal][:title]
        deal.amount=params[:deal][:amount]
        deal.initiated_by = current_user.id
        deal.assigned_to = params[:deal][:assigned_to]
        deal.country_id =  params[:deal][:country]
        deal.priority_type = current_user.organization.hot_priority()
        deal.deal_status = current_user.organization.deal_statuses.find(:first,:conditions=>["original_id=?",1])
        deal.is_active=true
        deal.is_current=false
        deal.is_public= true
        deal.deals_contacts.build(organization_id: deal.organization_id, contactable_id: contact.id, contactable_type: contact.class.name)
        deal.save
	      flash[:notice] = 'Lead has been saved successfully.'
        unless params[:allnew].nil? && params[:allnew].blank?
          update_deal_data(deal)
        end
        if !params[:allnew].nil? && !params[:allnew].blank?
	      
          redirect_to leads_path
        elsif params[:is_edit_deal] == 'true'
           #redirect_to edit_lead_path(deal)
           render :text=>"#{deal.id}" + '-success'
        else
           render :text=> 'success'
        end
    else
      render text: alert_msg.to_s
    end  
  end

def insert_opportunities deal   
    puts "==============       insert_opportunities   ========================"
   assigned_user = deal.assigned_user
   
   unless deal.assigned_user.nil? || deal.assigned_user != 0
     org_id = assigned_user.organization.id
     #org_id = current_user.organization
     current_quarter = get_current_quarter Date.today
     current_year = Time.zone.now.year
     case current_quarter
      when 1
        start_date = DateTime.new(Time.zone.now.year,1,1)
        end_date = DateTime.new(Time.zone.now.year,3,31)     
      when 2
        start_date = DateTime.new(Time.zone.now.year,4,1)
        end_date = DateTime.new(Time.zone.now.year,6,30)     
      when 3
        start_date = DateTime.new(Time.zone.now.year,7,1)
        end_date = DateTime.new(Time.zone.now.year,9,30)
      when 4
        start_date = DateTime.new(Time.zone.now.year,10,1)
        end_date = DateTime.new(Time.zone.now.year,12,31)     
      end

     assigned_deals = assigned_user.all_assigned_deal.by_is_active.by_range(start_date, end_date).count
     won_deals = get_deal_status_won_count(assigned_user,[4],start_date,end_date).count

     win_percentage = calculate_win_percentage(assigned_deals,won_deals)
     insert_or_update_opportunity(assigned_user.id, org_id, current_year, current_quarter, assigned_deals, won_deals, win_percentage)
   end
   puts "==============       insert_opportunities ends here  ========================"
  end
  
  def insert_opportunities_for_user user_id
      begin 
            puts "==============       insert_opportunities for user #{user_id}  ========================"
            assigned_user = User.find user_id.to_i
           
           if assigned_user.present?
             p assigned_user.id
             puts "=========> statrted processsing for user"
             org_id = assigned_user.organization.id
             #org_id = current_user.organization
             current_quarter = get_current_quarter Date.today
             current_year = Time.zone.now.year
             case current_quarter
              when 1
                start_date = DateTime.new(Time.zone.now.year,1,1)
                end_date = DateTime.new(Time.zone.now.year,3,31)     
              when 2
                start_date = DateTime.new(Time.zone.now.year,4,1)
                end_date = DateTime.new(Time.zone.now.year,6,30)     
              when 3
                start_date = DateTime.new(Time.zone.now.year,7,1)
                end_date = DateTime.new(Time.zone.now.year,9,30)
              when 4
                start_date = DateTime.new(Time.zone.now.year,10,1)
                end_date = DateTime.new(Time.zone.now.year,12,31)     
              end

             assigned_deals = assigned_user.all_assigned_deal.by_is_active.by_range(start_date, end_date).count
             won_deals = get_deal_status_won_count(assigned_user,[4],start_date,end_date).count

             win_percentage = calculate_win_percentage(assigned_deals,won_deals)
             insert_or_update_opportunity(assigned_user.id, org_id, current_year, current_quarter, assigned_deals, won_deals, win_percentage)
           end
           puts "==============       insert_opportunities for user ends here  ========================"
      rescue Exception => e 
        puts "==========> Heyy !! we got an error"
        puts e.message
        puts e.backtrace.inspect
      end
  end
  
  
  
  
  
  
  
  def insert_salescycle deal
   puts "==============        insert_salescycle deal         ========================"
     assigned_user = deal.assigned_user
     org_id = assigned_user.organization.id
     current_quarter = get_current_quarter Date.today
     current_year = Time.zone.now.year
     case current_quarter
      when 1
        start_date = DateTime.new(Time.zone.now.year,1,1)
        end_date = DateTime.new(Time.zone.now.year,3,31)     
      when 2
        start_date = DateTime.new(Time.zone.now.year,4,1)
        end_date = DateTime.new(Time.zone.now.year,6,30)     
      when 3
        start_date = DateTime.new(Time.zone.now.year,7,1)
        end_date = DateTime.new(Time.zone.now.year,9,30)
      when 4
        start_date = DateTime.new(Time.zone.now.year,10,1)
        end_date = DateTime.new(Time.zone.now.year,12,31)     
      end
  
      
    average_time = Deal.find_avg_deal_ratio_status_won assigned_user.id, org_id, start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")

    puts "===== average_time==========="   
     
   
     insert_or_update_salescycle(assigned_user.id, org_id, current_year, current_quarter, average_time[0], average_time[1], average_time[2])
      
  end
  
  def insert_deal_activity deal
    puts "###################Insert deal activity###############################"
   if deal
       org_id = deal.organization_id if deal.organization_id
       activity_type = deal.class.name
       activity_id =  deal.id       
       activity_user_id = deal.initiated_by ? deal.initiated_by : ""
       activity_date = deal.created_at
       activity_desc = deal.title
       activity_status = "Create"
       public_status = (deal.is_public.nil? ||  deal.is_public.blank?) ? false : deal.is_public 
       Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => activity_date, :is_public => true, :source_id => activity_id)       
       a1 = Activity.create(:organization_id => org_id,	:activity_user_id => deal.assigned_to.present? ? deal.assigned_user.id : "",:activity_type=> activity_type, :activity_id => activity_id, :activity_status => "Assign",:activity_desc=>activity_desc,:activity_date => activity_date, :is_public => true, :source_id => activity_id)
      if a1.id.present? && !deal.is_csv?
        deal.update_column :last_activity_date,  a1.activity_date
      end 
      # if deal.attachments
         # deal.attachments.each do |note|
            # if note.present?
              # a2 = Activity.create(:organization_id => note.organization_id,	:activity_user_id => note.created_by ? note.created_by : "",:activity_type=> note.class.name, :activity_id => note.id, :activity_status => "Create",:activity_desc=>note.notes,:activity_date => note.created_at, :is_public => true, :source_id => activity_id)
              # if a2.id.present?
                # deal.update_column :last_activity_date,  a2.activity_date  
              # end
            # end
         # end
      # end
	  #comment for initial note
      # if deal.comments
          # #a2 = Activity.create(:organization_id => org_id,  :activity_user_id => note.created_by ? note.created_by : "",:activity_type=> note.class.name, :activity_id => note.id, :activity_status => "Create",:activity_desc=>note.notes,:activity_date => note.created_at, :is_public => true, :source_id => activity_id)
          # a2 =Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id,:activity_type=> "Note", :activity_id => activity_id, :activity_status =>"Create",:activity_desc=>deal.comments ,:activity_date => activity_date, :is_public => true, :source_id => activity_id)
          # if a2.id.present?
            # deal.update_column :last_activity_date,  a2.activity_date  
          # end
      # end
     
      if deal.deals_contacts
         deal.deals_contacts.each do |contact|
           if contact.contactable
              record = contact.contactable         
              org_id = record.organization_id if record.organization_id
              activity_type = contact.contactable.class.name
              activity_id =  record.id       
              activity_user_id = record.created_by ? record.created_by : ""
              activity_date = record.created_at
              activity_desc = record.full_name
              activity_status = "Create"
              public_status = (record.is_public.nil? ||  record.is_public.blank?) ? false : record.is_public   
              
              a3 = Activity.create(:organization_id => org_id,	:activity_user_id => activity_user_id,:activity_type=> activity_type, :activity_id => activity_id, :activity_status => activity_status,:activity_desc=>activity_desc,:activity_date => activity_date, :is_public => true, :source_id => deal.id)
              if a3.id.present? && !deal.is_csv?
                 deal.update_column :last_activity_date,  a3.created_at
              end
           end
         end
      end
    end
  end
  
  def edit
    session[:prev_page] = nil
    session[:prev_page] = request.referer
    @deal = Deal.includes(:deals_contacts, :deal_source, :deal_industry).find(params[:id])
    @cat = @@category
    #@contact=@deal.deals_contacts.first.contactable
    #@work_phone = @contact.phones.by_phone_type "work"
    #@mobile_phone = @contact.phones.by_phone_type "mobile" 
  end
  
  def edit_deal
    session[:prev_page] = nil
    session[:prev_page] = request.referer
    @deal = Deal.includes(:deals_contacts, :deal_source, :deal_industry).find(params[:id])
    @cat = @@category
    render partial: "deal_edit", :content_type => 'text/html'
  end

  def update
    puts "------------------==========111111111111111 update"
    p params

    deal = Deal.find params[:id]
    update_deal_data(deal)
    if session[:prev_page].nil? || session[:prev_page].include?("/dashboard")
     session[:prev_page] = leads_path
    end    
    flash[:notice] = "Deal has been updated successfully."
    if !request.xhr?
      if params[:quick_edit].present?
       redirect_to request.referrer
      else
       redirect_to (session[:prev_page].nil? || session[:prev_page].include?('edit_individual_contact') || session[:prev_page].include?('edit_company_contact')) ? leads_path : session[:prev_page]
       session[:prev_page] = nil
      end
    else
      render :text=>"success"
    end
  end
  
  def deals_woking_on
   deal = Deal.find params[:id]
   deal.update_attribute(:is_current, true)
    redirect_to request.referer
  end
  
  def update_deal_data(deal)  
  
    #deal.title=params[:deal][:title]
    deal.title=params[:deal][:title] if params[:deal][:title]
    deal.amount=params[:deal][:amount]
    deal.assigned_to   = params[:deal][:assigned_to]
    #deal.tags = params[:deal][:tags]
    deal.tag_list = params[:deal][:tag_list]
    deal.comments = params[:deal][:comments]
    deal.probability = params[:deal][:probability]
    deal.attempts  = params[:deal][:attempts]
    deal.billing_type  = params[:deal][:billing_type] if params[:deal][:billing_type] 
	deal.payment_status  = params[:deal][:payment_status] if params[:deal][:payment_status]
    deal.priority_type = PriorityType.find(params[:deal][:priority_type]) if params[:deal][:priority_type]
    deal.is_public = params[:deal][:is_public]
    
    
    if params[:duration_type].present? && params[:deal][:duration].present?
        deal.duration = params[:deal][:duration] + "," + params[:duration_type]
    else
        deal.duration = nil
    end
    deal.save
    
    #save deal source
    
    if(deal.deal_source.nil? && !params[:deal][:deal_source].nil? && !params[:deal][:deal_source].blank?)
      dls = DealSource.create(:organization => current_user.organization,:deal=>deal,:source_id=> params[:deal][:deal_source])
    elsif (!deal.deal_source.nil? && !params[:deal][:deal_source].nil? && !params[:deal][:deal_source].blank?)
      deal.deal_source.update_attribute :source_id,params[:deal][:deal_source]
    end
    #save deal industry
    
    if(deal.deal_industry.nil? && !params[:deal][:deal_industry].nil? && !params[:deal][:deal_industry].blank?)
      dls = DealIndustry.create(:organization => current_user.organization,:deal=>deal,:industry_id=> params[:deal][:deal_industry])
    elsif (!deal.deal_industry.nil? && !params[:deal][:deal_industry].nil? && !params[:deal][:deal_industry].blank?)
      deal.deal_industry.update_attribute :industry_id,params[:deal][:deal_industry]
    end
    # save attachment
	
    #if(deal.attachment.nil? && (( !params[:deal][:attachment].nil? && !params[:deal][:attachment].blank?) || ( !params[:deal][:notes].nil? && !params[:deal][:notes].blank?)))
    #  note = Note.create(:organization => current_user.organization,:notes=>params[:deal][:notes], :notable=>deal,:attachment=> params[:deal][:attachment],:file_description=>params[:deal][:file_description],:created_by=>current_user.id)
    #elsif (!deal.attachment.nil? && (( !params[:deal][:attachment].nil? && !params[:deal][:attachment].blank?) || ( !params[:deal][:notes].nil? && !params[:deal][:notes].blank?)))
    #  deal.attachment.update_attributes(:notes=>params[:deal][:notes], :attachment=>params[:deal][:attachment],
    #      :file_description=>params[:deal][:file_description],:created_by=>current_user.id)
    #end
    
    # contact = deal.deals_contacts.first.contactable
    # if contact.class.name == "CompanyContact"
      # contact.update_attributes(organization_id: deal.organization_id,
                                # name: params[:deal][:name],
                                # company_strength_id: params[:deal][:company_strength],
                                # email: params[:deal][:email],
                                # messanger_type: params[:deal][:messanger_type],
                                # messanger_id: params[:deal][:messanger_id],
                                # website: params[:deal][:website],
                                # linkedin_url: params[:deal][:linkedin_url],
                                # facebook_url: params[:deal][:facebook_url],
                                # twitter_url: params[:deal][:twitter_url],
                                # created_by: current_user.id
                                # )
    # elsif contact.class.name == "IndividualContact"
      # contact.update_attributes(organization_id: deal.organization_id,
                                # first_name: params[:deal][:first_name],
                                # last_name: params[:deal][:last_name],
                                # email: params[:deal][:email],
                                # position: params[:deal][:position],
                                # messanger_type: params[:deal][:messanger_type],
                                # messanger_id: params[:deal][:messanger_id],
                                # website: params[:deal][:website],
                                # linkedin_url: params[:deal][:linkedin_url],
                                # facebook_url: params[:deal][:facebook_url],
                                # twitter_url: params[:deal][:twitter_url],
# #                                company_contact_id: 
                                # created_by: current_user.id
                                # )
    # end
# #    contact.organization = deal.organization
# #    contact.contact_type = params[:deal][:contact_type]
# #    contact.name = params[:deal][:name]
# #    contact.company_strength_id = params[:deal][:company_strength]
# #    contact.first_name = params[:deal][:first_name]
# #    contact.last_name = params[:deal][:last_name]
# #    contact.email = params[:deal][:email]
# #    contact.website = params[:deal][:website]
# #    contact.linkedin_url = params[:deal][:linkedin_url]
# #    contact.facebook_url = params[:deal][:facebook_url]
# #    contact.twitter_url = params[:deal][:twitter_url]
# #    contact.messanger_id = params[:deal][:messanger_id] 
# #    contact.messanger_type = params[:deal][:messanger_type]
# #    #contact.is_public=params[:deal][:is_public]
# #    contact.save
    # address = contact.address
    
    # if(address.nil?)
      # address = Address.new
    # end
    # address.city=params[:deal][:city]
    # address.state = params[:deal][:state]
    # address.country_id= params[:deal][:country]
    # address.zipcode = params[:deal][:zip_code]
    # address.address = params[:deal][:full_address]
    # address.organization=current_user.organization
    # address.addressable=contact
    # address.save
    # work_phone = contact.phones.by_phone_type "work"
    # mobile_phone = contact.phones.by_phone_type "mobile" 
    # if (!work_phone.blank?) && (!params[:deal][:work_phone].nil? || !params[:deal][:work_phone].blank?)
     # #work_phone.first.update_column :phone_no, params[:deal][:work_phone]
     # work_phone.first.update_attributes(:phone_no=>params[:deal][:work_phone],:extension=>params[:extension_contact_edit])
   # else
     # save_contact_to_phone contact,params[:deal][:work_phone], params[:extension_contact_edit],"work"
   # end
   # if (!mobile_phone.blank?) && (!params[:deal][:mobile_number].nil? || !params[:deal][:mobile_number].blank?)
     # #mobile_phone.first.update_column :phone_no, params[:deal][:mobile_number]
     # mobile_phone.first.update_attributes(:phone_no=>params[:deal][:mobile_number],:extension=>params[:extension_contact_edit])
   # else
     # save_contact_to_phone contact,params[:deal][:work_phone], params[:extension_contact_edit],"mobile"
   # end
    # if(@work_phone.nil?)
      # @work_phone= Phone.new
    # end    
    # ##save image to image
   # if (contact.image.nil?) && (!params[:deal][:contact_image].nil?) 
    # image = Image.create(:organization => current_user.organization,:image=>params[:deal][:contact_image], :imagable=>contact)
   # elsif (!contact.image.nil?) && (!params[:deal][:contact_image].nil?)
    # contact.image.update_attributes(:image=>params[:deal][:contact_image])
   # end  
    
    
  end
  
  def apply_label_to_deal
    deals = params[:deals].split(",")
    labels = params[:labels].split(",")
    deals.each do |dl|
      labels.each do |lbl|
        userdeal_label = DealLabel.find(:first,:conditions=>["user_label_id= ? and deal_id = ?",lbl,dl])
        p userdeal_label.nil?
        if(userdeal_label.nil?)
          DealLabel.create(:organization=>current_user.organization,:deal_id=>dl,:user_label_id=>lbl)
        end
      end
      
    end
    render :text=>"success"
  end
  
  def apply_label_to_single_deal
   labels = params[:labels].split(",")
    labels.each do |lbl|
      userdeal_label = DealLabel.find(:first,:conditions=>["user_label_id= ? and deal_id = ?",lbl,params[:deal]])
      if(userdeal_label.nil?)
        DealLabel.create(:organization=>current_user.organization,:deal_id=>params[:deal],:user_label_id=>lbl)
      end
    end
   render :text=>"success"
  end
  
  def move_deal
      puts "----------------- move deal"
      if params[:mass_deal_ids].present?
          response_msg = ""
          deal_ids = params[:mass_deal_ids].split(',')
          dealscount = deal_ids.length.to_i; 
          deal_ids.each do |d|
          deal = Deal.find d
          dm = DealMove.create(:organization=>current_user.organization,:deal_id=>d,:deal_status_id=>params[:deal_move][:deal_status],:user=>current_user)
                if !params[:deal_move][:note].nil? && !params[:deal_move][:note].blank?
                  Note.create(:organization=>current_user.organization,:notes=>params[:deal_move][:note],:created_by=>current_user.id,:notable=>dm)
                end
              deal.deal_status_id = params[:deal_move][:deal_status]
              deal.assigned_to 	 = params[:assigned_to_user]
              if(!params[:deal_move][:is_current].nil? && !params[:deal_move][:is_current].blank?)
	               deal.is_current= 0 if params[:deal_move][:is_current] == "1"
              end
	            if(dm.deal_status.original_id == 4 || dm.deal_status.original_id == 5 )
		            deal.is_current=false
	            end	        
	        deal.move_deal = true
          deal.save
          if d == deal_ids.last
             puts "----------------------------> yes last one"
               response_msg = {status: true, msg: "Deal has been moved successfully.", deal_org_id: deal.deal_status.original_id, total_deal: dealscount}
               p response_msg
         end
         if (dm.deal_status.original_id == 4)
	            deal.update_column :closed_by, current_user.id
              c_name = current_user.full_name
              NotifyMoveWonDeal.perform_async("#{current_user.organization_id}","#{deal.id}",c_name)
              InsertOpportunity.perform_async("#{deal.id}")    
              InsertSalescycle.perform_async("#{deal.id}")   
         else
               InsertOpportunity.perform_async("#{deal.id}")    
          end
          
         end
         
      else ## else of params[:mass_deal_ids].present?
        deal = Deal.find params[:deal_id]
        dealscount = 1;
        dm = DealMove.create(:organization=>current_user.organization,:deal_id=>params[:deal_id],:deal_status_id=>params[:deal_move][:deal_status],:user=>current_user)
        if !params[:deal_move][:note].nil? && !params[:deal_move][:note].blank?
          Note.create(:organization=>current_user.organization,:notes=>params[:deal_move][:note],:created_by=>current_user.id,:notable=>dm)
        end
        deal.deal_status_id = params[:deal_move][:deal_status]
        deal.assigned_to 	 = params[:assigned_to_user]
        if(!params[:deal_move][:is_current].nil? && !params[:deal_move][:is_current].blank?)
	      deal.is_current= 0 if params[:deal_move][:is_current] == "1"
        end
	     if(dm.deal_status.original_id == 4 || dm.deal_status.original_id == 5 )
		      deal.is_current=false
	    end
	      deal.move_deal = true
        deal.save
       if (dm.deal_status.original_id == 4)
	         deal.update_column :closed_by, current_user.id
              c_name = current_user.full_name
              #NotifyMoveWonDeal.perform_async("#{current_user.organization_id}","#{deal.id}",c_name)
              #InsertOpportunity.perform_async("#{deal.id}")    
              #InsertSalescycle.perform_async("#{deal.id}")   
        else ## else of dm.deal_status.original_id == 4
             #InsertOpportunity.perform_async("#{deal.id}")    
       end
       
   end
    
    
    
     puts "-------------------------------> "
     p dealscount
    # if !request.xhr?
     if params[:mass_deal_ids].present?
         #redirect_to leads_path
        # flash[:notice]="Deal has been moved successfully."
        # redirect_to request.referrer
      #  stage_info={status: true, msg: "Deal has been moved successfully.", stag_name: deal.deal_status_name, assigned_user: deal.assigned_user == @current_user ? "Me" : deal.assigned_user.full_name,assigned_user_id: deal.assigned_user.id,deal_org_id: deal.deal_status.original_id, total_deal: dealscount}
      stage_info= response_msg
      
     else
       stage_info={status: true, msg: "Deal has been moved successfully.", stag_name: deal.deal_status_name, assigned_user: deal.assigned_user == @current_user ? "Me" : deal.assigned_user.full_name,assigned_user_id: deal.assigned_user.id,deal_org_id: deal.deal_status.original_id, total_deal: dealscount}

     end 
     render :json => stage_info.to_json
  end
  
  def deal_setting
    if(!current_user.deal_setting.nil?)
      current_user.deal_setting.update_attributes :tabs=>params["tabs"].flatten.join(",")
    else
      DealSetting.create(:organization=>current_user.organization,:user=>current_user,:tabs=>params[:tabs].flatten.join(","))
    end
    
    redirect_to leads_path
  end
  
  
  def delete_selected_deals
    puts "000)))))000))000)))0000000))000)))0)))000)000)))0"
    p params
      if params[:deal_ids_to_delete].include?(',')
        deal_ids=params[:deal_ids_to_delete].chop
      else
        deal_ids=params[:deal_ids_to_delete] 
      end
      deal_ids=deal_ids.split(",")
      puts "<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>"
      p deal_ids
      deal_ids.each do |id|
        deal=Deal.where(id: id).first
        p deal
        if deal 
          unless deal.assigned_to.present?
            puts "============>  delaas"
            p deal.id
            deal_contact = deal.deals_contacts.first.contactable
            
            puts "############################################"
            p deal_contact
            if deal_contact.deals_contacts.present? && deal_contact.deals_contacts.count == 1
              #
              #
               puts "$$$$$$$$$$$$$$$$$$$$$$$$$$"
              
               if deal_contact.class.name == "IndividualContact"
                con = IndividualContact.find deal_contact.id
               elsif deal_contact.class.name == "CompanyContact"
                con = CompanyContact.find deal_contact.id
               end
               
              #contact.address.destroy
              #contact.phones.destroy
              #contact.deals_contacts.destroy
              con.destroy
              deal.destroy
            else
             deal.destroy
            end
          else
            deal.is_active=false
            deal.save
            deal.tasks.each do |cmp|
              cmp.update_column :is_completed, true
            end
          end
        end
        flash[:notice] = "Deal(s) has been deleted successfully!"
      end
      respond_to do |format|
        format.js { render text: "success" }
      end
  end
  
  def destroy  
    
    puts "=============="
    
    @deal = Deal.find(params[:id])
    return_url = @deal.is_remote? ? leads_path(:type=>"un_assigned") : leads_path
    if params[:type].present? && params[:type] == "unassigned"
      puts "============>  delaas"
      p @deal.id
      deal_contact = @deal.deals_contacts.first.contactable
      
      puts "############################################"
      p deal_contact
      if deal_contact.deals_contacts.present? && deal_contact.deals_contacts.count == 1
        #
        #
         puts "$$$$$$$$$$$$$$$$$$$$$$$$$$"
        
         if deal_contact.class.name == "IndividualContact"
          con = IndividualContact.find deal_contact.id
         elsif deal_contact.class.name == "CompanyContact"
          con = CompanyContact.find deal_contact.id
         end
         
        #contact.address.destroy
        #contact.phones.destroy
        #contact.deals_contacts.destroy
        con.destroy
        @deal.destroy
      else
       @deal.destroy
      end
      
    else        
           # if(@deal.deal_status.is_incoming?)
          # @deal.destroy

        # else
	      if @deal
            @deal.is_active=false
            @deal.save
            @deal.tasks.each do |cmp|
             cmp.update_column :is_completed, true
            end
         end
    end
   respond_to do |format|
      format.html { redirect_to return_url , notice: "Deal has been deleted successfully!"}
      format.js { render text: "success" }
    end
  end
  
 def deal_task_widget
    deal=Deal.find params[:deal_id]
	  @tasks=[]
    @tasks=Task.task_list(current_user, params[:task_type], deal)if current_user.present? && deal.present?
    @task_type = params[:task_type] if params[:task_type].present?
    render partial: "widget_task_list" #, :content_type => 'text/html'
 end
 
 def task_widget_reload
    @deal=Deal.find params[:deal_id]
    render partial: "widget_task_header" #, :content_type => 'text/html'
 end 
 
def bulk_lead_upload
   CSV.foreach(params[:attachment_lead].path, headers: true, encoding: 'ISO-8859-1') do |row|        
    #row['created_dt'] = Date.strptime row['created_dt'], '%Y-%m-%d'
    #row['created_dt']=DateTime.strptime(row['created_dt'], "%m/%d/%Y").strftime("%Y/%m/%d")    
    
    fields_to_insert = %w{ user_id title priority company_name company_size website contact_name designation phone extension mobile email technology source location country industry comments created_dt description assigned_to facebook_url linkedin_url twitter_url skype_id task_type}
    rows_to_insert = []
    row['user_id']  = current_user.id
    if row['company_size']
      row['company_size'] = row['company_size'].gsub(/[()]/, "")
    end
    
    if row['assigned_to']
      unless assigned_to_users.include?(row['assigned_to'].to_s)
         row['assigned_to'] = nil
      end
    end
    
    alltask_types = current_user.organization.task_types.map{|c| c.name.downcase.strip}
    if (!row['task_type'].present?) || !(alltask_types.include?(row['task_type'].downcase) )
        row['task_type'] = "call"
    end
    
    row['created_dt'] = Date.parse(row['created_dt'].to_s)
    time_to_merge = Time.zone.now
    date_to_merge = row['created_dt'].to_date
    merged_datetime = DateTime.new(date_to_merge.year, date_to_merge.month,date_to_merge.day, time_to_merge.hour, time_to_merge.min, time_to_merge.sec)
    
    creadat = row['created_dt'].to_date
    if creadat >= Date.today
       row['created_dt'] = Time.zone.now
    else
        row['created_dt'] =  merged_datetime
    end
    
    row_to_insert = row.to_hash.select { |k, v| fields_to_insert.include?(k) }
    rows_to_insert << row_to_insert
    unless row['title'].nil? ||  row['title'].blank?
      TempLead.create! rows_to_insert
    end
   end
   respond_to do |format|
      format.text {render text: "success"}
   end
 end
 
 def lead_preview
   @c = []
   @leads = TempLead.by_user current_user.id
   @country = Country.all
   @country.each do |a|
    @c << a.name
   end
   
 end
 
 def destroy_all_lead
  @leads = TempLead.by_user current_user.id
  @leads.destroy_all
  redirect_to leads_path
 end
 
 def save_lead
  ActiveRecord::Base.connection.execute("CALL import_leads_to_deals(#{current_user.id})")
  flash[:notice] = "Leads have been uploaded successfully."
  
  OpportunityAfterLead.perform_async
  LeadNotification.perform_async
  redirect_to leads_path
 end
 
 def save_lead_phone
   lead = TempLead.find params[:name]
   if params[:pk] == "1"
     lead.update_column :phone, params[:value]
   elsif params[:pk] == "2"
     lead.update_column :mobile, params[:value]
   end
   #respond_to do |format|
      format.text {render text: "success"}
    #end
 end
 
 
 def save_lead_email
  lead = TempLead.find params[:name]
  lead.update_column :email, params[:value]
  respond_to do |format|
      format.text {render text: "success"}
    end
 end
 
def save_lead_data
   @c = []

   lead = TempLead.find params[:name]
   if params[:pk] == "1"
     lead.update_column :title, params[:value]
	 msg = "success"
   elsif params[:pk] == "2"
     lead.update_column :company_name, params[:value]
	  msg = "success"
   elsif params[:pk] == "3"
     lead.update_column :company_size, params[:value]
   elsif params[:pk] == "4"
     lead.update_column :source, params[:value]
   elsif params[:pk] == "5"
     lead.update_column :website, params[:value]
   elsif params[:pk] == "6"
     lead.update_column :contact_name, params[:value]
   elsif params[:pk] == "7"
     lead.update_column :designation, params[:value]
   elsif params[:pk] == "8"
     lead.update_column :phone, params[:value]
   elsif params[:pk] == "9"
     lead.update_column :mobile, params[:value]
   elsif params[:pk] == "10"
     lead.update_column :email, params[:value]
   elsif params[:pk] == "11"
     lead.update_column :technology, params[:value]
   elsif params[:pk] == "12"
     lead.update_column :location, params[:value]
   elsif params[:pk] == "13"
     lead.update_column :country, params[:value]
	 @country = Country.all
     @country.each do |a|
      @c << a.name
     end
   elsif params[:pk] == "14"
     lead.update_column :industry, params[:value]
   elsif params[:pk] == "15"
     lead.update_column :comments, params[:value]
   elsif params[:pk] == "16"
     lead.update_column :description, params[:value]
   elsif params[:pk] == "17"
     lead.update_column :assigned_to, params[:value]
   elsif params[:pk] == "18"
     lead.update_column :facebook_url, params[:value]
   elsif params[:pk] == "19"
     lead.update_column :twitter_url, params[:value]
   elsif params[:pk] == "20"
     lead.update_column :linkedin_url, params[:value]
   elsif params[:pk] == "21"
     lead.update_column :skype_id, params[:value]
   end
   if (params[:pk].present? && !@c.include?(params[:value]))
    msg = "error_#{lead.id}"
   else
    msg = "success_#{lead.id}"
   end
   respond_to do |format|
   #if (!@c.include?(l.country))
     #format.text {render text: "error"}
   #else
     format.text {render text: msg}
   #end
  end
end
 
 def learnmore 
   render :layout => false
 end
 
def add_contact
  
  if !params[:contactable_id].present?
    ic= IndividualContact.new
    ic.organization_id=current_user.organization_id
    ic.first_name = params[:first_name]
    ic.email = params[:email]
    ic.country = params[:country]
    ic.work_phone = params[:work_phone]
    ic.extension = params[:extension_contact_popup]
    ic.created_by = current_user.id
    ic.company_contact_id=params[:comp_id] if params[:comp_id].present?
    ic.save
    DealsContact.create(:organization_id => current_user.organization_id,:deal_id =>params[:deal_id],:contactable_type => "IndividualContact",:contactable_id => ic.id)
    if !params[:comp_id].present? && params[:company_value].present?
      cc=CompanyContact.new
      cc.organization = current_user.organization
      cc.name = params[:company_value]
      cc.country = params[:country]
      cc.work_phone = params[:work_phone]
      cc.time_zone = params[:time_zone][:contact]
      cc.created_by = current_user.id
      if cc.save(validate: false)
        ic.update_column(:company_contact_id, cc.id)
      end
    end
  else
  DealsContact.create(:organization_id => current_user.organization_id,:deal_id =>params[:deal_id],:contactable_type => params[:contactable_type],:contactable_id => params[:contactable_id])
  end
  
  if !request.xhr?
    flash[:notice] = "Contact has been added successfully."
    redirect_to request.referrer
  else
    render :text => "Contact has been added successfully."
  end
 end
 
 def delete_deal_con
  @deal_con = DealsContact.find(params[:id])
  deal= @deal_con.deal
  @deal_con.destroy
  deal.update_country_id
  flash[:notice] = "Contact has been deleted successfully."
  redirect_to request.referrer
 end
 def update_deal_ttl
  deal = Deal.find params[:name]
  deal.update_column :title, params[:value]
  respond_to do |format|
     format.text {render text: "success"}
  end
 end
 def update_note_ttl
  activity = Activity.find params[:name]
  note = Note.find activity.activity_id
  activity.update_column :activity_desc, params[:value].gsub(/\n/,"<br>")
  activity.update_column :updated_at, Time.now
  note.update_column :notes, params[:value].gsub(/\n/,"<br>")
  respond_to do |format|
     format.text {render text: activity.updated_at.strftime("%I:%M %p").to_s+"~"+activity.id.to_s}
  end
 end
def hide_note
  activity = Activity.find params[:id]
  activity.update_column :is_available, true
  respond_to do |format|
     format.text {render text: activity.id}
  end
 end
 def fetch_activity
  if(@deal = Deal.where(:id => params[:id].to_i).first).present?
   respond_to do |format|
      format.text {render partial: "time_line_stream"}
    end
   end
 end

  def fetch_user_deals
    @user = User.find params[:id]
    @deals = @user.all_assigned_or_created_deals.limit(10)
    respond_to do |format|
      format.text {render partial: "users/deal_list"}
    end

  end


  def get_industry_list
    if params[:type] == "industry"
      data = @current_organization.industries.select("id value, name text").where("name IS not NULL")
    elsif params[:type] == "source"
      data = @current_organization.sources.select("id value, name text").where("name IS not NULL")
    end
    
    respond_to do |format|
      #format.html 
      format.json { render json: data .to_json}
    end
  end

  def get_country_list
   data = Country.select("id value, name text")
   respond_to do |format|
      #format.html 
      format.json { render json: data .to_json}
    end
  end
  
  def save_country_lead   
   #{"name"=>"34", "value"=>"7", "pk"=>"1"}
   cname = Country.where(:id=>params[:value]).first.name
   if cname.present?
    TempLead.find(params[:name]).update_attribute(:country, cname)   
   end
   render text: 'success' 
  end

  def get_user_list_lead
   if params[:from].present? 
      #data = @current_organization.users.where("invitation_token IS ? and is_active = ?", nil,true).select("id value, (case when id = " + @current_user.id.to_s + " then 'me' else CONCAT(first_name,' ',last_name) end) text").order("first_name")
      data = @current_organization.users.where("invitation_token IS ? and is_active = ? and first_name IS NOT NULL and last_name IS NOT NULL", nil,true).select("id value, (case when id = " + @current_user.id.to_s + " then 'me' else CONCAT(first_name,' ',last_name) end) text").order("first_name")
   else
       data = @current_organization.users.where("invitation_token IS ? and is_active = ?", nil,true).select("id value, email text")
   end
   respond_to do |format|
      #format.html 
      format.json { render json: data .to_json}
    end
  end
 
 def save_user_lead
  uemail = User.where(:id=>params[:value]).first.email
  if uemail.present?
    TempLead.find(params[:name]).update_attribute(:assigned_to, uemail)       

  end 
  render text: 'success' 
 end
 
 def get_task_type_lead
    data = @current_organization.task_types.select("name value, name text")

   respond_to do |format|
      #format.html 
      format.json { render json: data .to_json}
    end
  end
 
 
 def save_task_type_lead
   puts "------------------save_task_type_lead"
   TempLead.find(params[:name]).update_attribute(:task_type, params[:value])     
   render text: 'success' 
 end
 
 
 def save_compsize_lead
   TempLead.find(params[:name]).update_attribute(:company_size, params[:value])     
   render text: 'success' 
 end
 
  def save_deal_industry

    if params[:pk] == "industry"
      deal = DealIndustry.where(:deal_id=> params[:deal_id]).first
      if deal.present?
        deal.update_column :industry_id, params[:value] 
      else
        DealIndustry.create(:organization => @current_organization,:deal_id=>params[:deal_id],:industry_id=> params[:value])
      end
      response_txt = Industry.get_name(params[:value]).to_json
    elsif params[:pk] == "source"
      deal = DealSource.where(:deal_id=> params[:deal_id]).first
      if deal.present?  
        deal.update_column :source_id, params[:value] 
      else
        DealSource.create(:organization => @current_organization,:deal_id=>params[:deal_id],:source_id=> params[:value])
      end
      response_txt = Source.get_name(params[:value]).to_json
    end
      respond_to do |format|
      #format.html 
      format.json { render text: response_txt }
    end    
    #render text: 'success' 
  end

  def reassign_user_to_deals
    p params[:reassign_deal_ids]
    p params[:reassigned_to]
    if params[:reassign_deal_ids].present? && params[:reassigned_to].present?
      if params[:reassign_deal_ids].include?(',')
      deal_ids=params[:reassign_deal_ids].chop
      else
        deal_ids=params[:reassign_deal_ids] 
      end
      p deal_ids=deal_ids.split(",")
      p user=User.where(:id => params[:reassigned_to]).first
      if user.present?
        if (deals=Deal.where(:id => deal_ids)).first.present?
          deals.update_all(:assigned_to => user.id,:is_remote => 0)
          if !params[:reassign_deal_ids].include?(',')
             Deal.where(:id => deal_ids).update_all(:is_remote => 0)
           end
           deals.map {|deal| deal.reassign_actvity }
          SendEmailNotificationDeal.perform_async(user.email,user.full_name,nil,nil,deal_ids, true)
        end
      end
    end
    render text: "success"
  end
  
  
  def quick_deal
        @deal = Deal.find params[:deal_id]
        render partial: "quick_edit"
  end
  
  def get_contact
    @deal = Deal.find(params[:dealid])
    if params[:individual] == 'true'
      @contact = IndividualContact.find(params[:contact_id])
    else
      @contact = CompanyContact.find(params[:contact_id])
    end
    @cat = @@category
    @work_phone = @contact.phones.by_phone_type "work"
    @mobile_phone = @contact.phones.by_phone_type "mobile"     
    render partial: "shared/get_contact", :content_type => 'text/html'
  end

  def created_by_user
    #data = @current_organization.users.where("invitation_token IS ? and is_active = ?", nil,true).select("id value, email text")
     data = all_org_users
     @users = all_org_users
     data = @users.map do |u|
       { :id => u.id, :fname => u.full_name }
     end
  
     
    respond_to do |format|
      #format.html 
      format.json { render json: data .to_json}
    end  
  end
 
def deal_detail_contacts
  @deal = Deal.find params[:dealid]
  respond_to do |format|
      format.text {render partial: "deal_contacts"}
    end
end
 
def deal_files
  @attach = Note.where("notable_type =? and notable_id=?", "Deal", params[:dealid]).order("id desc")
  @deal = Deal.find params[:dealid]
  respond_to do |format|
      format.text {render partial: "files"}
    end
end
 def delete_note_attachment
  @note_act = NoteAttachment.find(params[:id])
  @note_act.attachment.destroy
    @note_act.attachment= nil
    @note_act.save
  flash[:notice] = "Attachment file has been deleted successfully."
  redirect_to request.referrer
 end 
def edit_note
	nt = Note.find params[:noteid]
	nt.update_attribute(:is_public, params[:note][:is_public])
	flash[:notice] = "Privacy setting of the file has been saved successfully."
	redirect_to request.referrer
end
  def deal_location_filter
   @country = Country.all
    data = @country.map do |c|
       { :id => c.id, :cname => c.name }
     end
     respond_to do |format|
      #format.html 
      format.json { render json: data .to_json}
    end  
  end
  
  def change_assigned_to
      if params[:value].present? && !params[:value].nil?
          if(deal = Deal.where(:id => params[:name]).first).present?
          #expire_action(:controller => 'deals', :action => 'show', :id =>deal.id) ##expiring action cache
          deal.update_column(:assigned_to, params[:value])        
          deal.reassign_actvity
          deal.update_column :last_activity_date, Time.zone.now
          deal.update_column(:is_remote, false) #if (params[:type].present? && params[:type] == "unassigned")
          #if (user=User.where(:id => params[:value]).first).present?
            #SendEmailNotificationDeal.perform_async(user.email,user.full_name,nil,nil,deal.id, true)
         # end
          render text: 'success' 
       end
        
      end 
  end
  
  def assigned_deal_leaderboard
        puts "--------------------assigned_deal_leaderboard"
        p params
       # {"user_id"=>"246", "start_date"=>"2014-01-01", "end_date"=>"2014-03-31", "action"=>"assigned_deal_leaderboard", "controller"=>"deals"}
        user = User.find params[:user_id]
        @deals = user.all_assigned_deal.by_is_active.includes(:deal_status).by_range(params[:start_date].to_date,params[:end_date].to_date)
        #respond_to do |format|
         # #format.html 
        #  format.js { render text: 'ss'}
       # end
       render :partial=> "assigned_deal_leaderboard"
  end
  def upload_multiple_note_attach
    puts "######################################"
    p params
    tf=TempFileUpload.create :user_id=>current_user.id,:attachment=> params[:myfile]
    respond_to do |format|
      format.json { render json: {:message=>"success",:id=> tf.id}}
      
    end
    #render :text =>{:message=>"success",:id=> tf.id}
  end
  def delete_temp_note_attach
    
    tf=TempFileUpload.find params[:tf_id]
    tf.destroy
    render text: "success"
      
    
  end
  
  
  def send_weekly_digest_email
    unless current_user.is_admin?  || current_user.is_super_admin?
       flash[:alert]="It seems you don't have sufficient privilege to access this item or something went wrong with your account permissions.<br/> Please contact Admin to get this fixed." 
       redirect_to root_path
       return 
    else
      SendWeeklyEmail.perform_async("#{current_user.organization_id}")
      flash[:notice]="Mail sent successfully." 
      redirect_to root_path
    end
  end
  
  def accept_assign_deal
      puts "accept_assign_deal ====================="
      begin 
        crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
        decrypted_lead_token = crypt.decrypt_and_verify(params[:hot_lead_token])
        user_id = crypt.decrypt_and_verify(params[:user_id])
        if(deal = Deal.where("hot_lead_token =?", decrypted_lead_token).first).present?
          cookies[:redirect_deal_id] = deal.id
          deal.update_attributes :assigned_to=> user_id, :is_remote=> false, :hot_lead_token => nil, :token_expiry_time => nil, :next_priority_id => nil, :assignee_id => nil
          flash[:notice] = "Deal has been accepted successfully."
        else
          flash[:alert] = "Token has already been expired!"
        end
       rescue => e
            file = File.new("#{Rails.root}/log/accept_hot_lead.log", "a")          
            file.puts 'Error while accepting' + ' ' + "executed on" + ' ' + Time.now.utc.to_s 
            file.puts "Mesage:" + e.message.to_s
            file.puts "Mesage:" + e.backtrace.to_s
            file.puts "----------------------------------------> <----------------------------------------------"
            file.close
          p e.message
          flash[:alert] = "Invalid token!"
       end    
       redirect_to root_path
  end  
  
  def deny_assign_deal
    puts "deny_assign_deal ====================="
    begin 
        crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
        decrypted_lead_token = crypt.decrypt_and_verify(params[:hot_lead_token])
        user_id = crypt.decrypt_and_verify(params[:user_id])
        if(deal = Deal.where("hot_lead_token =?", decrypted_lead_token).first).present?
           start_process_of_assigning_deal deal.id, assigned_to=nil, hot_lead_token=nil, 'deny'
           flash[:notice] = "You have successfully denied the request of accepting the deal."
        else
          flash[:alert] = "Token has already been expired!"
        end
       rescue => e
            file = File.new("#{Rails.root}/log/deny_hot_lead.log", "a")
            file.puts 'Error while denying' + ' ' + "executed on" + ' ' + Time.now.utc.to_s 
            file.puts "Mesage:" + e.message.to_s
            file.puts "Mesage:" + e.backtrace.to_s
            file.puts "----------------------------------------> <----------------------------------------------"
            file.close
          p e.message
          flash[:alert] = "Invalid token!"
       end    
    redirect_to root_path    
  end
  
end


