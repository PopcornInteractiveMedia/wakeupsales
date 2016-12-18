class SearchController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

require 'will_paginate/array' 

  def show
    begin
       expire_fragment("header_right_menu_admin_true")
       expire_fragment("header_right_menu_admin_false")
       p_page = params[:page].nil? ? 1 : params[:page].to_i
       page_number = params[:page].nil? ? 1 : params[:page].to_i
       orgid= @current_organization.id.to_s + ''
       unless (must_email=validate_email(params[:query])) || (must_phone=validate_phone(params[:query]))
           query = params[:query]+"*"
          if params[:type].present?
            search = Tire.search ["#{params[:type]}"], :page=> p_page, :per_page=>20, :load => true do
          # search = Tire.search [  'individual_contacts'], :page=> p_page, :per_page=> 20, :load => true do
             query { string query } if query.present?
             
              filter :term, :organization_id => orgid
              filter :term, :is_active => true
              
              to_hash[:filter] = { :and => to_hash[:filter] }
              from  ((p_page-1)*20)
              size 20
           end
          else
           search = Tire.search [ 'deals','tasks', 'individual_contacts', 'company_contacts',  'notes'], :page=> p_page, :per_page=>20, :load => true do
          # search = Tire.search [  'individual_contacts'], :page=> p_page, :per_page=> 20, :load => true do
             query { string query } if query.present?
             
              filter :term, :organization_id => orgid

              filter :term, :is_active => true
              to_hash[:filter] = { :and => to_hash[:filter] }
              from  ((p_page-1)*20)

              size 20
           end
          end
        
        else
          type=params[:type].split(",") if params[:type].present?
          if !params[:type].present? || (type.present? && (type.include?('individual_contacts') || type.include?('company_contacts')))
            search_from=[]
            if type.present?
               search_from <<  'individual_contacts' if type.include?('individual_contacts')
               search_from <<  'company_contacts' if type.include?('company_contacts')
            else
              search_from = [ 'individual_contacts', 'company_contacts']
            end
            
            search_from << 'deals'
            query_value=params[:query]
            search = Tire.search search_from, :page=> p_page, :per_page=>20, :load => true do
                query do
                  boolean do
                    if must_email == true
                      #must { match :email, query_value, :type => :phrase} if query_value.present?
                      must { match :contacts_email, query_value, :type => :phrase} if query_value.present?
                    elsif must_phone == true
                      query_value="("+query_value.split("(")[1] if query_value.split("(")[1]
                      #must { match :phone_number, query_value, :type => :phrase} if query_value.present?
                       must { match :contacts_phone_no, query_value, :type => :phrase} if query_value.present?
                    end
                  end
                end
                filter :term, :organization_id => orgid
                filter :term, :is_active => true
                
                to_hash[:filter] = { :and => to_hash[:filter] }
                from  ((p_page-1)*20)
                size 20
             end
             @results = search.results
           else
             @results =[]
           end
          end
         @results = search.results
         @count = @results.count
         @total_pages =@count
     rescue Exception => e
     end
  end
  
  def validate_email(value)
    r=false
    begin
      m = Mail::Address.new(value)
      r = m.domain && m.address == value
      t = m.__send__(:tree)
      r &&= (t.domain.dot_atom_text.elements.size > 1)
    rescue Exception => e
      r = false
    end
    r
  end
  def validate_phone(value)
    regular_exp=/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/
    phone=false
    if regular_exp =~ value
      phone=true
    end
    phone
  end
  
end