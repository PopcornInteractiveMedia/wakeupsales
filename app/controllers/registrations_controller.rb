class RegistrationsController < Devise::RegistrationsController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  skip_before_filter :authenticate_user!, :except => [:update]
  def new
    super
  end

  def create
    # add custom create logic here 
    if params[:user][:is_beta_user] == "1"
      buser = BetaAccount.find_by_email params[:user][:email]
      if buser.present?
        org = Organization.new(name: params[:user][:organization_name], size_id: params[:user][:organization_size], website: params[:user][:organization_website],email: params[:user][:email], beta_account_id: buser.id)
      end
    else
        org = Organization.new(name: params[:user][:organization_name], size_id: params[:user][:organization_size], website: params[:user][:organization_website],email: params[:user][:email])
    end    
    org.save
    params[:user].delete(:organization_name)
    params[:user].delete(:organization_size)
    params[:user].delete(:organization_website)
    build_resource sign_up_params
    resource.organization = org   #******** here resource is user 
    resource.admin_type = 1
    if params[:user][:is_beta_user] == "1"
       resource.skip_confirmation!
       resource.confirm!
    end
    params[:user].delete(:is_beta_user)
    if resource.save
      if !resource.organization.beta_account_id.nil? ||  !resource.organization.beta_account_id.blank?
       #buser.update_column :is_registered, true
       buser.update_attributes :is_registered => true, :invitation_token => nil
       sign_in(:user, resource)
       redirect_to after_sign_in_path_for(resource)
      else
        if resource.active_for_authentication?
           set_flash_message :notice, :signed_up if is_navigational_format?
           #sign_in(resource_name, resource)
           respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
     end
    else
      clean_up_passwords resource
      respond_with resource
    end
    
  end

  def update
    super
  end
end 
