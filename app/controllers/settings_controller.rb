class SettingsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

   skip_before_filter :authenticate_user!, :only => [:unscribe_latest_blog]
  def index
  end
  
  def save_group
    if(!params[:name].nil? && !params[:name].blank? &&  params[:id].nil?)
      
      role =Role.new(name: params[:name],organization: @current_user.organization)
      role.save!
      respond_to do |format|
        format.text {render text: role.id}
      end
    elsif(!params[:name].nil? && !params[:name].blank? && !params[:id].nil?)
      role= Role.find(params[:id])
      role.update_attribute :name, params[:name]
      respond_to do |format|
        format.text {render text: "success"}
      end
    else
      respond_to do |format|
        format.text {render text: "Please enter name"}
      end
    end
  end
  
  def get_group
    if(!params[:sort].nil? && !params[:sort].blank? && !params[:order].nil? && !params[:order].blank?)
      #groups = @current_user.organization.roles.order(params[:sort] + " " +  params[:order]).all
	  groups = Role.where("organization_id	=?", @current_organization.id).order(params[:sort] + " " +  params[:order])
    else
      #groups = @current_user.organization.roles.all
	  groups = Role.where("organization_id	=?", @current_organization.id)
    end
    respond_to do |format|
      #format.html 
      format.json { render json: groups.to_json }
    end
  end
  
  def delete_group
   group= Role.find(params[:id])
   group.destroy
   render :text=> "success"
  end
  
  #update the priority as per organization
  def update_priority_org    
   PriorityType.update_priority_name params[:hot], params[:warm], params[:cold], @current_organization.id
   render :partial => "priority"
  end
  
  #update the deal statuses as per organization
  def update_deal_status
    DealStatus.update_status params[:deal], params[:qualify], params[:not_qual], params[:won], params[:lost], params[:junk], @current_organization.id
    render :partial => "deal_status"
  end
  
  #update the priority as per organization
  def update_feed_keyword_org
   org = FeedKeyword.find_by_organization_id @current_organization.id
   if org.nil? || org.blank?   
     og = FeedKeyword.new(feed_tags: params[:keywords],organization: @current_organization)
     og.save!
   else
     org.update_attribute :feed_tags, params[:keywords]
   end
   render :partial => "feeds"
  end
  
  
  def update_widget_org
    #Parameters: {"chart"=>"1", "activity"=>"1", "feeds"=>"1", "tasks"=>"1", "page"=>"widget"}
    puts "------------------------ update_widget_org"
    ##FIXME AMT
    org = Widget.find_by_organization_id_and_user_id @current_organization.id, @current_user.id     
    if params[:page] == "widget"
        if org.nil? || org.blank?   
          og = Widget.new(chart: params[:chart],activities: params[:activity],:summary=> params[:summary],:usage=> params[:usage], tasks: params[:tasks],organization_id: @current_organization.id, user: @current_user)
          og.save!
        else
          org.update_attributes :chart=>params[:chart], :activities => params[:activity], :summary=> params[:summary],:usage=> params[:usage], :tasks => params[:tasks]
        end 
         render :partial => "widgets" 
    elsif params[:page] == "chart"
  	if org.nil? || org.blank?   
          og = Widget.new(line_chart: params[:linechart],pie_chart: params[:piechart],column_chart: params[:columnchart],statistics_chart: params[:statisticschart],organization_id: @current_organization.id, user: @current_user)
          og.save!
        else
          org.update_attributes :line_chart => params[:linechart], :pie_chart => params[:piechart],column_chart: params[:columnchart],statistics_chart: params[:statisticschart]
        end
  render :partial => "chart" 
    end
   
  end
def save_source
    source= Source.new
    source.organization = @current_organization
    source.name = params[:value]
    if source.save
     #source= Source.create(:organization=>current_user.organization,:name=>params[:value])
	   #source= Source.create(:organization=>current_user.organization,:name=>params[:source][:name])
	   if params[:from] == "editdeal" && !params[:pk].nil?
	     deal = DealSource.where(:deal_id=> params[:pk].to_i).first
        if deal.present?  
          deal.update_column :source_id, source.id
        else
          DealSource.create(:organization => @current_organization,:deal_id=>params[:pk].to_i,:source_id=> source.id)
        end
	   end
     flash[:notice] = "Source has been added successfully."
     render :text=> source.id.to_s + "-" + source.name
    else
      msgs=source.errors.messages
      render :text=> "exists"
    end
  end
  
  def save_industry
    industry= Industry.new
    industry.organization = @current_organization
    industry.name = params[:value]
    #industry= Industry.create(:organization=>current_user.organization,:name=>params[:value])
	#industry= Industry.create(:organization=>current_user.organization,:name=>params[:industry][:name])
    if industry.save
     #source= Source.create(:organization=>current_user.organization,:name=>params[:value])
	   #source= Source.create(:organization=>current_user.organization,:name=>params[:source][:name])
	 if params[:from] == "editdeal" && !params[:pk].nil? 
	 deal = DealIndustry.where(:deal_id=> params[:pk].to_i).first
      if deal.present?
        deal.update_column :industry_id,industry.id
      else
        DealIndustry.create(:organization => @current_organization,:deal_id=>params[:pk].to_i,:industry_id=> industry.id)
      end
     end
     flash[:notice] = "Industry has been added successfully."
     render :text=> industry.id.to_s + "-" + industry.name
    else
      msgs=industry.errors.messages
      render :text=> "exists"
    end
  end
  def save_label
    label= UserLabel.create(:organization=> @current_organization,:name=>params[:user_label][:name],:color=>params[:user_label][:color],:user=> @current_user)
    render :text=> label.id.to_s + "-" + label.name
  end
  def save_user_label
    if(!params[:name].nil? && !params[:name].blank? && !params[:color].nil? && !params[:color].blank? &&  params[:id].nil?)
      
      label= UserLabel.create(:organization=> @current_organization,:name=>params[:name],:color=>params[:color],:user=> @current_user)
      respond_to do |format|
        format.text {render text: label.id}
      end
    elsif(!params[:name].nil? && !params[:name].blank? && !params[:color].nil? && !params[:color].blank? && !params[:id].nil?)
      label= UserLabel.find(params[:id])
      label.update_attributes( :name=> params[:name],
        :color=>params[:color])
      respond_to do |format|
        format.text {render text: "success"}
      end
    else
      respond_to do |format|
        format.text {render text: "Please enter name and color"}
      end
    end
    
    
    #render :text=> label.id.to_s + "-" + label.name
  end
  def get_user_label
    if(!params[:sort].nil? && !params[:sort].blank? && !params[:order].nil? && !params[:order].blank?)
      labels = @current_user.user_labels.order(params[:sort] + " " +  params[:order]).all
    else
      labels = @current_user.user_labels if current_user.present? && current_user.user_labels.present?
    end
    respond_to do |format|
      #format.html 
      format.json { render json: labels.to_json }
    end
  end
  def update_user_label
    
  end
  
  def edit_source
    source= Source.find(params[:source_id])
    #msgs=source.errors.messages  
     source.update_attributes(:name=> params[:name])      
      if source.errors.messages.present?
       msgs=source.errors.messages
      else
       msgs="success"
      end  
    render :text=> msgs
	   #respond_to do |format|
        #format.text {render text: "success"}
      #end
  end
  def edit_industry
    ind= Industry.find(params[:industry_id])
    ind.update_attributes(:name=> params[:name])
    
    if ind.errors.messages.present?
       msgs=ind.errors.messages
      else
       msgs="success"
      end
      render :text=> msgs
	#respond_to do |format|
        #format.text {render text: "success"}
      #end
  end  
  def update_org_settings
   org = Organization.find current_user.organization.id
   puts "################################"
  
   org.update_attributes(params[:organization])
   current_user.update_column :time_zone,params[:organization][:time_zone]
   flash[:notice] = "Updated Successfully"
   redirect_to request.referrer
  end 

  def delete_label
   label= UserLabel.find(params[:id])
   label.destroy
   render :text=> "success"
  end  
 def update_notification
   email_notify = EmailNotification.find_by_user_id @current_user.id
   if email_notify.nil? || email_notify.blank?
	 email = EmailNotification.new(user_id: @current_user.id,due_task: params[:tasks],task_assign: params[:task_assign], deal_assign: params[:deal_assign], donot_send: params[:donot_send])
     email.save!
   else
	 email_notify.update_attributes :user_id=> @current_user.id, :due_task=>params[:tasks], :task_assign => params[:task_assign], :deal_assign=> params[:deal_assign], :donot_send => params[:donot_send]
   end
   render :partial => "email_notification" 
  end
  
  def get_task_outcome_label
    t_out = TaskOutcome.all
    respond_to do |format|
      format.json { render json: t_out.to_json }
    end
  end
  
  def save_task_outcome_label
     puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
     p params
     if(params[:name].present? && params[:task_type_name].present? && params[:task_duration_name].present? &&  !params[:id].present?)
         
        t_out= TaskOutcome.create(:name=> params[:name],:task_out_type=>params[:task_type_name],:task_duration=>params[:task_duration_name])
        respond_to do |format|
          format.text {render text: t_out.id}
        end
     elsif(params[:name].present? && params[:task_type_name].present? && params[:task_duration_name].present? && params[:id].present?)
       taskoutcome= TaskOutcome.find(params[:id])
       taskoutcome.update_attributes( :name=> params[:name],:task_out_type=>params[:task_type_name],:task_duration=>params[:task_duration_name])
       respond_to do |format|
         format.text {render text: "success"}
       end
     else
       respond_to do |format|
         format.text {render text: "Please enter task outcome name, type and duration"}
       end
    end
  end
  
  def delete_taskoutcome
    puts "delete_taskoutcome=========================="
    p params
    taskoutcome= TaskOutcome.find(params[:id])
    taskoutcome.destroy
    render :text=> "success"
  end
  
  def fetch_pages
    case params[:tab]
      when "sns"
        render :partial => "sns"
      when "widgets"
        render :partial => "widgets"
        
      when "chart"
        render :partial => "chart"
        
      when "group"
        render :partial => "groups"
        
      when "org"
        render :partial => "org"

      when "task_outcome"
        render :partial => "task_outcome"

      when "priority"
        render :partial => "priority"
        
      when "deal"
        render :partial => "deal_status"
        
      when "user_label"
        render :partial => "user_label"
        
      when "api_token"
        render :partial => "api_token"

	  when "weekly_digest"
        render :partial => "weekly_digest"
    end
    
  end
  
  
  def update_weekly_digest
    if(!request.xhr?)
      crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
      decrypted_user_id = crypt.decrypt_and_verify(params[:user_id])
      user_preference = UserPreference.find_by_user_id decrypted_user_id
      user_preference.update_attributes :weekly_digest=> 0
      flash[:notice] = "Weekly digest updated successfully."
      redirect_to root_path
    else
      user_preference = UserPreference.find_by_user_id params[:user_id]
      if params[:weekly_digest] == "0"
        user_preference.update_attributes :weekly_digest=>params[:weekly_digest]
      else
        user_preference.update_attributes :digest_mail_frequency=>params[:frequency_digest] ,:weekly_digest=>params[:weekly_digest]
      end
      render :partial => "weekly_digest"
    end
  end
  
  def unscribe_latest_blog
    if(!request.xhr?)
      crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
      decrypted_user_id = crypt.decrypt_and_verify(params[:contact_id])
      ind_cont = IndividualContact.find decrypted_user_id
      ind_cont.update_attributes :subscribe_blog_mail=> 0
      flash[:notice] = "You'll no longer receive emails about Andolasoft Blog updates."
      redirect_to root_path
    else
      ind_cont = IndividualContact.find params[:contact_id]
      ind_cont.update_attributes :subscribe_blog_mail=>params[:latest_blog]
      render :partial => "latest_blog_notification"
    end
  end

end