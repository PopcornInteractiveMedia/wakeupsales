class ApplicationController < ActionController::Base

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  require 'net/http'
  require 'uri'
  #require 'nokogiri'
  
  protect_from_forgery
  include BootstrapFlashHelper
  include ApplicationHelper

  before_filter :set_returnurl
  before_filter :set_timezone 
  before_filter :chk_inactive_user
  before_filter :authenticate_user!, :except => [:create_admin_user]
  before_filter :set_user  ##to get current user object in observer
  before_filter :set_cache_buster #preventing browser cache


  def chk_inactive_user
     if current_user.present? && !current_user.is_active?
         reset_session
	       flash[:notice]="Your account is de-activated"
          redirect_to "/users/sign_in"
	      return
     end
  end

  def expire_fragment(fragment, options = nil)
    puts "-------------------inside exsspire frgament"
    if Rails.configuration.cache_store.include?(:redis_store)
    #views/localhost:3000/terms
    #views/localhost:3000/deals/10301
    unless (fragment.include?("/terms") || fragment.include?("/privacy") || fragment.include?("/security") || fragment.include?("/leads/") )
     # if fragment.is_a?(Regexp)
        puts "----------------------inside if"
        fragment = "#{fragment.to_s.split(':').last.gsub(')', '')}*"
      end
    end
    super
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  

  def set_returnurl
	  if (request.fullpath != "/users/sign_in" && request.fullpath != "/users/sign_up" && request.fullpath != "/users/password" && request.fullpath != "/users/sign_out" && !request.xhr?) # don't store ajax calls
		  session[:return_to] = request.fullpath 
	  end
  end
  
  def set_timezone 
    Time.zone = current_user.time_zone if current_user && current_user.time_zone.present?
  end 

  def get_contacts
  #  if(!params[:org_id].nil?)    

   #  query = params[:q]+"*"
    # p_page = params[:page].nil? ? 1 : params[:page].to_i
     # search = Tire.search [ 'individual_contacts', 'company_contacts'], :page=> p_page, :per_page=> 20 do
      #  query { string query} 
       # filter :term, :is_active => true
        #from  ((p_page-1)*20)
        #size 100
     #end

    # results = search.results
     #result_details=[]
      #results.map do |result|
#        if result.class.name == "Contact"
#        end
     
        ## disabled public deals view by normal user
        #if ((result.organization_id == current_user.organization.id) && (result.contact_status == true) && ((result.is_public == true) || ((result.created_by == current_user.id) || (current_user.is_admin?))))
       # if ((result.organization_id == current_user.organization.id) && (result.contact_status == true) && (((result.created_by == current_user.id) || (current_user.is_admin?))))

        #  result_details << {
         #         id: result.id,
          #        name: result.title,
           #       email: result.email,
            #      country_id: result.country_id,
             #     phone_no: result.phone_number,
              #    company_type: result.class.name,
               #   is_active: result.contact_status,
                #  is_public: result.is_public,
                #  created_by: result.created_by,
                 # comp_name: (result.class.name == "IndividualContact" ? (comp = CompanyContact.where(id: result.company_contact_id).first).present? ? comp.title : "" : ""),
                 # time_zone:  (result.class.name == "IndividualContact" ? (comp = CompanyContact.where(id: result.company_contact_id).first).present? ? comp.time_zone : "Hawaii" : "Hawaii")
                 # }
        #end
      #end
	result_details=[]
   query = params[:q]+"*"
   individual_contacts = IndividualContact.search_by(query)
   company_contacts = CompanyContact.search_by(query)
   results = individual_contacts + company_contacts
   results.map do |result|
     result_details << {
                   id: result.id,
                   name: result.title,
                   email: result.email,
                   country_id: result.country_id,
                   phone_no: result.phone_number,
                   company_type: result.class.name,
                   is_active: result.contact_status,
                   is_public: result.is_public,
                   created_by: result.created_by,
                   comp_name: (result.class.name == "IndividualContact" ? (comp = CompanyContact.where(id: result.company_contact_id).first).present? ? comp.title : "" : ""),
                   time_zone:  (result.class.name == "IndividualContact" ? (comp = CompanyContact.where(id: result.company_contact_id).first).present? ? comp.time_zone : "Hawaii" : "Hawaii")
                   }
    end
    respond_to do |format|
     format.json { render json: result_details }
    end
  end 

  def get_deals
    if(!params[:org_id].nil?)
	      if !current_user.is_admin?
	           deals = current_user.my_deals_dashboard.where("title like ? and is_active = ?","%"+params[:q]+"%",true).select("title as deal_name, id")
	      else
	           deals = Deal.where("deals.organization_id = ? and title like ? and is_active = ?",params[:org_id],"%"+params[:q]+"%",true).select("title as deal_name, id")
	      end
      respond_to do |format|
        format.json { render json: deals }
      end
    end
  end

  def get_companies
    if(!params[:org_id].nil?)
      if current_user.is_admin?
        companies = CompanyContact.where("organization_id = ? and name like ? and is_active = ?",params[:org_id],"%"+params[:q]+"%",true).select("name as company_name, id, time_zone")
      else

        ## disabled public deals view by normal user
        #companies = CompanyContact.where("organization_id = ? and name like ? and is_active = ? and (is_public = ? or created_by = ?)",params[:org_id],"%"+params[:q]+"%",true,true,current_user.id).select("name as company_name, id")
        companies = CompanyContact.where("organization_id = ? and name like ? and is_active = ? and ( created_by = ?)",params[:org_id],"%"+params[:q]+"%",true,current_user.id).select("name as company_name, id")

      end
      respond_to do |format|
        format.json { render json: companies }
      end
    end
  end


  def get_extension
    country = Country.find params[:id]
    respond_to do |format|
      format.json { render json: {extension: country.isd_code}}
    end  
  end

  def get_country_states
    country = Country.find params[:id]
    states = ISO3166::Country[country.ccode].states.map { |k, v| v['name'] } rescue []
    respond_to do |format|
      format.json { render json: {states: states}, status: :ok }
    end
  end

  def page_not_found_error
     flash[:notice]="The page you are looking for is not available."
  end


  def add_notes    
     if params[:notable_type] == "CompanyContact" || params[:notable_type] == "IndividualContact"
      obj = params[:notable_type].constantize.find params[:notable_id]
    elsif  params[:notable_type] == "Deal"
      obj = Deal.find params[:notable_id]
    end
    note_count = 0
    if(!obj.nil?)
	  @n = Note.create(:organization => current_user.organization,:notes=>params[:note][:notes], :notable=>obj,:file_description=>params[:note][:file_description], :created_by => current_user.id, :is_public=>params[:note][:is_public])   
      if params[:remove_file_ids].present?
       rem_id = (params[:remove_file_ids].chomp).split(',')
      end
      if(params[:temp_file_ids].nil?)
        params[:note][:attachment].each_with_index do |att,i|   
           if att.present?
           @n.note_attachments.create(:note_id=> @n.id,:attachment=> att) unless rem_id.present? && rem_id.include?(i.to_s) 
          end
       end 
       note_count=params[:note][:attachment].count
      else
			tempids = (!params[:temp_file_ids].nil? && !params[:temp_file_ids].blank? ? params[:temp_file_ids].split(",") :"")

		if(!tempids.nil? && !tempids.blank?)	
			tempids.each do |tfid|
			  if(!tfid.nil? && tfid != "" )
				tf=TempFileUpload.find tfid
				if(!tf.nil?)
				  @n.note_attachments.create(:note_id=> @n.id,:attachment=> tf.attachment)
				  tf.destroy
				  note_count = note_count +1
				end
			  end
			end
		end
      end
      a1 = Activity.create(:organization_id =>  current_user.organization_id,	:activity_user_id => current_user.id,:activity_type=> "Note", :activity_id => @n.id, :activity_status => "Create",:activity_desc=>params[:note][:notes],:activity_date => Time.zone.now, :is_public => true, :source_id => @n.notable_id)
      if(params[:notable_type] == "Deal")
       obj.update_column :last_activity_date,a1.activity_date
      else
       ActivitiesContact.create(:organization_id => current_user.organization_id, :activity_id=> a1.id,:contactable_type=>params[:notable_type],:contactable_id=> params[:notable_id])
      end
    end

    if params[:note_from_deal] == "true" || params[:note_from_deal] == true
      note=Note.where("organization_id=? AND notes=? AND notable_type=? AND notable_id=? AND created_by=?",current_user.organization, params[:note][:notes], obj.class.name, obj.id, current_user.id ).first
       today = Time.now.strftime('%Y-%m-%d')
       yesterday = (Time.now - (24 * 60 * 60)).strftime('%Y-%m-%d')
       if(Date.today.to_s == DateTime.parse(note.created_at.to_s).strftime('%Y-%m-%d').to_s)
          day = "Today"
       elsif(yesterday.to_s == DateTime.parse(note.created_at.to_s).strftime('%Y-%m-%d').to_s)
         day = "Yesterday"
        else
         day =""
       end
      note= {
               created_at: note.created_at.strftime("%I:%M %p"),
               created_date: note.created_at.strftime("%y%m%d"),
               note: note.notes,
               create_day:day,
               created_id:note.created_by,
               created_by: (note.user.id == current_user.id) ? "me" : note.user.full_name,
               attachment_present: note.note_attachments.present?,
               attachment_url: note.attachment_urls,
               attachment_name: note.attachment_name,
               file_desc: note.file_description,
               type: params[:notable_type],
               activity_id: a1.id,
               note_count: note_count
            }
      respond_to do |format|
        format.json { render json: note}
      end
    else
      render :text => "success"
    end
  end

  ##For nonadmin user statistics
  def insert_or_update_opportunity assigned_user_id, org_id, current_year, current_quarter, assigned_deals, won_deals, win_percentage
     op =Opportunity.where(:user_id=> assigned_user_id , :year=> current_year , :quarter=> current_quarter).first
   if op.present?
     op.update_attributes :total_deals => assigned_deals, :won_deals => won_deals, :win => win_percentage                      
   else                  
      Opportunity.create! :user_id => assigned_user_id , :organization_id => org_id, :year => current_year, :quarter => current_quarter, :total_deals => assigned_deals, :won_deals => won_deals, :win => win_percentage
   end
  end

  

  def insert_or_update_salescycle(assigned_user_id, org_id, current_year, current_quarter, average, shortest, longest)
   sc =SalesCycle.where(:user_id=> assigned_user_id , :year=> current_year , :quarter=> current_quarter).first
   if sc.present?
     sc.update_attributes :average => average, :shortest => shortest, :longest => longest            
   else                  
      SalesCycle.create! :user_id => assigned_user_id , :organization_id => org_id, :year => current_year, :quarter => current_quarter, :average => average, :shortest => shortest, :longest => longest
   end
  end

  def calculate_deals_rate filtered_user, total_user
    result = (filtered_user.to_f / (total_user.to_f - 1)).to_f*100
    result = result.nan? ? "" : result.round(2)
  end

  def calcalute_avg_deal_org  avg_days, total
    result = avg_days.to_i / total.to_i
    result
  end

  

  def load_all_partials
    render partial: "shared/load_all_partials"
  end

  

  def render_notification_area
    render :partial=> "shared/notification_section"
  end

  

  def header_user_info
    render partial: "shared/header_user_info"
  end

  



  private

  ##redirect the user after login

  def after_sign_in_path_for(resource)
    ##To start the attention deal work as a background process after login
#    AttentionDealWorker.perform_async(current_user.id)
    @current_user=current_user
    @current_organization=current_user.organization
    
   expire_fragment "header_logo"
   if !session[:from_mail].nil? || !session[:from_mail].blank?  
     users = User.select(:id).where("organization_id=?", @current_organization.id).collect(&:id).to_a  
     if users.include? session[:from_mail].to_i 
       "/leads?assigned_to=#{session[:from_mail].to_i}"
     else 
       "/"
     end
   elsif @current_user.activities.first.present?
     static_url = ["/terms","/privacy","/security"]
	 (session[:return_to].nil? || (static_url.include? session[:return_to])) ? dashboard_url : session[:return_to].to_s
   else
     if @current_user.is_siteadmin?
	 dashboard_url
	 else
	   getting_started_url
	 end
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    puts "-----------------------=========--``````````````-------------"
    ##clearing the fragments that have been stored
    expire_fragment "organization_users"
    expire_fragment "organization_users_task"
    expire_fragment "task_types"
    expire_fragment "header_logo"
    #expire_fragment "User-#{@current_user.id}-headerInfo"
    #expire_fragment "user_menu_#{@current_user.id}"
    expire_fragment "all_partial_files"
    root_path
  end

  def authenticate_user!
   session[:from_mail] = nil
   if params[:assigned_to].present? 
     session[:from_mail] = params[:assigned_to]
   end  
   super
  end



  def authenticate_admin 
    if user_signed_in? && current_user && (current_user.admin_type== 1 or current_user.admin_type== 2 or params[:action] == "change_password")
      return true
    else
      flash[:alert]="You don't have sufficient permission to view this page."
      redirect_to "/"
    end
  end

  

   def set_user
    if user_signed_in?
      User.current = current_user
      @current_organization=current_user.organization
    end
  end


end


