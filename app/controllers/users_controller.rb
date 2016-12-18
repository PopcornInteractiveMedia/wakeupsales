class UsersController < ApplicationController

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
  cache_sweeper :user_sweeper
  before_filter :authenticate_admin, :except => [:update_profile_image,:save_tmp_img, :get_user_email, :profile,:save_profile_info, :update, :save_password,:load_header_count_user, :create_admin_user]
  before_filter :assign_user, :except => [:profile, :create_admin_user]

  
  def assign_user
     @user = current_user
  end

  def invite_user
   user = User.where("email = ?", params[:user][:email]).first
   if !user.present?
    begin
      user=User.new(params[:user])
      user.organization= current_user.organization
      user.password=user.organization.name[0..5]+"@123"
      user.build_user_role(:role_id=> params[:user][:role_id], :organization_id => user.organization_id) if params[:user][:admin_type] == "3"
      respond_to do |format|
        user.confirm!
        user.skip_confirmation!
        if user.save
          user.invite!(@user)
          flash[:notice]="Invitation email has been sent to the user."
          format.js  {render :nothing => true}
        else
          alert_msg=""
          msgs=user.errors.messages
          msgs.keys.each_with_index do |m,i|
            alert_msg=m.to_s.camelcase+" "+msgs[m].first
            alert_msg += "<br />" if i > 0
          end
         p alert_msg
        format.json { render json: user.errors, status: :unprocessable_entity }
        format.js {render text: alert_msg.to_s}
        end
      end
    rescue => e
      p e.message
      flash[:notice]=e.message
      redirect_to "/dashboard"
    end
   else
    if user.organization_id == @current_organization.id
     render text: "Email has already been taken!"
    else
     render text: "User is already invited by other organization!"
    end
   end
  end
  
  def edit
    @user=User.where("id=?",params[:id]).first
  end
  
  def update
    @user=User.where("id=?",params[:id]).first
        
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.update_column :role_id, params[:user][:role_id]
        expire_fragment("user_menu_#{@user .id}") #if fragment_exist?("user_menu_#{@user .id}")
        format.html { redirect_to request.referer, notice: 'User has been updated successfully.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def index
    #@users =current_user.organization.users.includes(:user_role).where("is_active =?", true).limit(50).order("users.admin_type, user_roles.role_id").group_by{|u| !u.first_name.nil? ?  u.first_name[0].upcase : ""}
    @users =current_user.organization.users.includes(:user_role).order("users.admin_type, user_roles.role_id").group_by{|u| !u.first_name.nil? ?  u.first_name[0].upcase : ""}
  end
  
  def destroy
    user = User.find(params[:id])
    #user.destroy
	user.update_column(:is_active,false)
    respond_to do |format|
      flash[:notice]="User successfully inactive."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def get_user_email
    respond_to do |format|
      format.json { render json: {email: User.find(params[:id]).email}}
    end
  end
  
  def save_password
    if @user.update_attributes(params[:user])
      redirect_to root_path
    else
      respond_to do |format|
        format.html { render :action => "change_password" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  def get_source_list
    render :partial=> "users/source_list"
  end
  
  def get_industry_list
    render :partial=> "users/industry_list"
  end
 def source_list
    respond_to do |format|
      format.html
      format.json { render json: SourcesDatatable.new(view_context) }
    end
  end
  
 def delete_source
    source = Source.find(params[:id])
    source.destroy
	respond_to do |format|
      flash[:notice]="Source has been successfully deleted."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
 end 
  
  def industry_list
    respond_to do |format|
      format.html
      format.json { render json: IndustriesDatatable.new(view_context) }
    end
  end
  def delete_industry
    industry = Industry.find(params[:id])
    industry.destroy
	respond_to do |format|
      flash[:notice]="Industry has been successfully deleted."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
    
  def save_profile_info
    @user = User.find params[:name]
    if params[:pk] == "1"
     @user.update_attributes({first_name: params[:value]})
    elsif params[:pk] == "2"
     @user.update_attributes({last_name: params[:value]})
    elsif params[:pk] == "3"
     @user.phone.update_attributes({phone_no: params[:value]})
    elsif params[:pk] == "4"
     @user.update_attributes({time_zone: params[:value]})
    end
    # expire_fragment("user_menu_#{@user .id}") #if fragment_exist?("user_menu_#{@user .id}")
    render :text => @user.full_name
  end
  
  def resend_invitation
    User.find(params[:user_id]).invite!
    flash[:notice]="Invitation email has been re-sent to the user."
    redirect_to request.referrer
  end
  
  def profile
    @all_users = User.where("organization_id=?",@current_organization.id)
    #@all_users =current_user.organization.users
    
   begin
     @user = params[:id].present? ? (@all_users.find(params[:id])) : @current_user
    #@user = params[:id].present? ? @all_users.find(params[:id]) : @current_user
      
   unless @current_user.is_siteadmin?
      @allowed_user =  !params[:id].present? ? true : (( params[:id].to_i == current_user.id ) || (current_user.is_admin? || current_user.is_super_admin?) ? true : false)
    end

     
   rescue ActiveRecord::RecordNotFound
      flash[:alert]="No such user exist!"
      redirect_to profile_path
    end
  
  end
  
  def enable_usr
    usr = User.find params[:id]
    usr.update_attribute(:is_active, true)
    flash[:notice]="User has been successfully activated."
    redirect_to request.referrer
  end

  def create_admin_user
    User.create(:email => params[:user][:email],:password => params[:user][:password],:organization_id => 1, :admin_type => 1,:confirmation_token=>nil, :confirmed_at=>Time.now)
    redirect_to root_path, notice: "Successfully created admin user."
  end
  
  def edit_user
   @user = User.find(params[:user_id])
    render partial: "edit_user", :content_type => 'text/html'
  end
  
  def load_header_count_user
      unless @current_user.is_siteadmin?
        @tasks=nil
        @tasks=Task.task_list(@user, "today") if @user.present?
	    @tasks = @tasks.limit(10) if !@tasks.empty?
        @task_type="today"      
        count_condition=get_deal_status_count_user([1,2,3,4,5,6],@user)
        @new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) ", [1]).count
        @working_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) AND is_current=? ", [1,2,3,4,5,6], true).count
        @qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?)", [2]).count
        #@deals = @user.all_assigned_or_created_deals.limit(10)
      
          if badge_today_user(@user) > 0
            @task_count = badge_today_user(@user)
            @task_text="Today's tasks"
            @task_url = "/tasks?type=today"
          elsif badge_overdue_user(@user) > 0
            @task_count = badge_overdue_user(@user)
            @task_text="Overdue tasks"
            @task_url = "/tasks?type=overdue"
          elsif badge_upcoming_user(@user) > 0
            @task_count = badge_upcoming_user(@user)
            @task_text="Upcoming tasks"
            @task_url = "/tasks?type=upcoming"
          else
            @task_count = badge_all_user(@user)
            @task_text="Tasks"
            @task_url = "/tasks"
          end
          @allowed_user =  !params[:id].present? ? true : (( params[:id].to_i == current_user.id ) || (current_user.is_admin? || current_user.is_super_admin?) ? true : false)
          render partial: "user_load_header_count_section", :content_type => 'text/html'
     end
  end
def save_tmp_img
    text="fail"
    #if remotipart_submitted?
	puts ">>>>>>>>>>>..this is before checking user"
      @user=User.where("id=?", params[:user_id]).first
	  p @user
	  puts ">>>>>>>>>>>..getting user"
      if @user.present?
	   begin
	   puts ">>>>>>>>>>>..if useris present"
	   @tempImage= TempImage.create!(:user_id=> @user.id, :avatar=> params[:user][:profile_image])
	   text="success" if !@tempImage.nil?
	   rescue => e
	    p e.message
		p e.backtrace
	    text="fail" 
	   end
      end
    #end
    if text=="success"
      render partial: "crop"
    else
      render :text => text
    end
  end
  
  
  def update_profile_image
	@user=User.where("id=?",params[:user_id]).first	
	
	respond_to do |format|
	  @tmpimage=TempImage.find params[:id]
	  @tmpimage.crop_x =params["temp_image"]["avatar"]["crop_x"]
	  @tmpimage.crop_y =params["temp_image"]["avatar"]["crop_y"]
	  @tmpimage.crop_w =params["temp_image"]["avatar"]["crop_w"]
	  @tmpimage.crop_h =params["temp_image"]["avatar"]["crop_h"]
      @tmpimage.crop
	  
	  if(@user.image.update_attribute :image,@tmpimage.avatar)
    expire_fragment("user_menu_#{@user.id}")
		@tmpimage.destroy
		format.json{render json: {imagesmall: @user.image.image.url(:small) ,imageicon: @user.image.image.url(:icon)}}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
