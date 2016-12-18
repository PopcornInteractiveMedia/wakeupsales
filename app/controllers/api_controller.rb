class ApiController < ApplicationController
# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

skip_before_filter  :authenticate_user!, :only => [:save_bug_report]
skip_before_filter  :verify_authenticity_token, :only => [:save_bug_report]
 include HotLeadAssignment


 def api_contact_us
   xml_start_node = "<message>"
   xml_end_node = "</message>"
   if (params[:email] != "") && (params[:name] != "") && (params[:message] != "") &&  (params[:phone] != "") 
      build_contact_us_info(params[:email],params[:name],params[:message], params[:phone], true)
      msg = xml_start_node +"<success>Successfully saved the contact us information.</success>"+ xml_end_node
   else
      msg = xml_start_node +"<error>Error while saving contact us information.</error>"+ xml_end_node
   end
   respond_to do |format|
      format.json  { render :json => Hash.from_xml(msg).to_json }  
   end
 end

def createLead
  
   my_logger ||= Logger.new("#{Rails.root}/log/myAPI.log")
   my_logger.info("--------parameters--------------at---"+ Time.now.to_s + "-----------")
   my_logger.info(params)
   my_logger.info("------------------------end------------------------\n")
   xml_start_node = "<message>"
   xml_end_node = "</message>"
   if params[:authkey]  && (@org = Organization.find_by_auth_token(params[:authkey]))

         my_logger.info("--------------Organization details----------------")
		 my_logger.info(params[:authkey])
		 my_logger.debug(@org)
         admin_user = User.where("organization_id=? and admin_type=1", @org.id).first
         my_logger.debug(admin_user)
		 
            if params[:countrycode]
             cntry= Country.find_by_ccode(params[:countrycode]).id
           else
             cntry = 236
           end
             cname = ""
             if params[:path]
                cname = params[:username] 
             else
               cname = params[:name] 
              end
            if params[:company] || params[:website]
               contactid= save_company_contact(cname, params[:email], params[:phone],cntry ,admin_user.id,params[:gmtoffset],params[:company],params[:website], @org) 
            else
              contactid= save_individual_contact(cname, params[:email], params[:phone],cntry ,admin_user.id,params[:gmtoffset], @org) 
            end
              
        
              if contactid
                
                deal = Deal.new
                deal.organization = @org
                 title= "Lead from "+ @org.name.gsub(" ", "-")
                 msg = ""
                 sourc= ""
                if  params[:form_name] == 'request-a-quote' || params[:form_name] == 'contact-us'
                  title = (params[:type_app].present? ?  params[:type_app] : "") + " App development " + params[:start_proj]
                  msg = params[:msg]
                  #subject = 
                end
               if  params[:form_name] == 'railsexpertz'
                  msg = params[:message]
               end
                if params[:tech] && ( params[:form_name] == 'free_security_test' || params[:form_name] == 'aws_managed_services')
                   title = params[:form_name].gsub("_", " ").strip.titleize
                   msg = params[:tech]
                end
                
                 if params[:template] && ( params[:form_name] == 'free-templates')
                   title = params[:form_name].gsub("-", " ").titleize + "-" + params[:template]
                   msg = "Downloaded Free Template"+ params[:template].gsub("-", " ").titleize + " for " + params[:purpose]
                end
                
                if params[:path].present?
                  title = params[:path].gsub("/" ," ").gsub("lp","").strip.gsub(" ","-")
                  msg = params[:message]
                  sourc = @org.name.gsub(" ", "-") + params[:path].gsub("/", "-")
                  ppc_subject = params[:path].gsub("/", "-").split("-")[2]
                elsif params[:form_name].present?
                  sourc =params[:form_name].gsub("_", "-")
                end
                
                 if params[:form_name] == 'invoice-generator' || params[:form_name] == "electronic_signature_for_pdf"
                   title = params[:form_name].gsub("_", "-").gsub("-", " ").strip.titleize
                   msg = params[:reason]
                end
                
                
                deal.title=title
                deal.initiated_by = admin_user.id
                deal.country_id =  cntry
                deal.priority_type =@org.hot_priority()
                deal.deal_status = @org.deal_statuses.find(:first,:conditions=>["original_id=?",1])
                deal.is_active=true
                deal.is_current=false
                deal.is_public= true
                deal.last_activity_date = Time.zone.now
                #deal.country_id = cntry
                deal.is_remote = 1
                deal.comments = msg
                deal.deals_contacts.build(organization_id: @org.id , contactable_id: contactid.id , contactable_type: contactid.class.name)
                deal.referrer = params[:referrer] if params[:referrer].present?
                deal.visited = params[:visited] if params[:visited].present?
                deal.location_by_api = params[:location] if params[:location].present?
                deal.save
                update_source(deal,sourc,@org)
                #admin_user = User.where("organization_id=? and admin_type in(1,2) and is_active=1",ENV['andolaORG'].to_i).select(:email).map(&:email).join(",")
                
                if (userlable = UserLabel.find_by_organization_id_and_name @org.id, "Inbound").present?
                    label = userlable
                else
                    label = UserLabel.create organization: @org, user: admin_user, name: "Inbound", color: "#cf5353"
                end
                DealLabel.create(:organization=>@org,:deal_id=>deal.id,:user_label_id=>label.id)
                
                if ENV['mode'] == "production"
                  #admin_user = User.where("organization_id=? and admin_type in(1,2) and is_active=1",ENV['andolaORG'].to_i).select(:email).map(&:email).join(",")
                  if @org.name == "Andolasoft" || @org.id.to_i == 1
                    admin_user = User.where("organization_id=? and admin_type in(1) and is_active=1",@org.id.to_i).select(:email).map(&:email)
                    admin_user =  admin_user.push("anurag.pattnaik@andolasoft.com").join(",")
                  else
                     admin_user = User.where("organization_id=? and admin_type in(1,2) and is_active=1",@org.id.to_i).select(:email).map(&:email).join(",")
                  end
                else
                  admin_user = "amit.mohanty@andolasoft.co.in,suman.panda@andolasoft.co.in"
                end
                src = @org.name.gsub(" ", "-") + "-" + sourc
                if params[:path]
                  subject = "ppc-" + ppc_subject
                else
                   subject = "web-" + sourc
                end
                
                lnk= ENV['url'] +"leads/" + deal.id.to_s
                if params[:phone].present?
                 contact_phone = "(+" + cntry.to_s + ")" + params[:phone].to_s 
                end
              #  Notification.mail_to_admin_api(admin_user, src, lnk, cname, params[:email],  contact_phone,msg,subject).deliver 
                msg = xml_start_node +"<success>Successfully saved Information.</success>"+ xml_end_node
                ###primary deal assigning proces according to user priority level
                 begin 
                   insert_or_update_token_info_inbound(deal,from='api')
                 rescue => e
                   puts "-------------- got the error"
                   p e.message
                   p deal
                   deal.update_attributes :hot_lead_token => nil, :token_expiry_time => nil, :next_priority_id =>nil , :assignee_id => nil
                 end
                #################################
           else
               msg = xml_start_node +"<error>Error while saving.</error>"+ xml_end_node
         end
  else
    msg = xml_start_node +"<error>Invalid AuthKey</error>"+ xml_end_node
  end

  respond_to do |format|
      format.json  { render :json => Hash.from_xml(msg).to_json }  
   end 
  
end

 def update_source(deal,src,org)
   if src
     src = org.name.gsub(" ", "-") + "-" + src
     extsrc = Source.where("name=?",src).first
     if !extsrc.present?
      source= Source.new
      source.organization = org
      source.name = src
      source.save
     end
     dealsrc = DealSource.where(:deal_id=> deal.id).first
      if dealsrc.present? && extsrc.present? 
        dealsrc.update_column :source_id, extsrc.id
      else
        if  extsrc.present?
        DealSource.create(:organization =>org,:deal_id=>deal.id,:source_id=> extsrc.id)
        else
          DealSource.create(:organization =>org,:deal_id=>deal.id,:source_id=> source.id) 
        end
      end
    end
 end
 
  def save_company_contact(myname,email,phoneno,country,admin,timezoneoffset,company,website, org) 
    compContact = CompanyContact.where("email =? and organization_id=?", email, org.id.to_i)
    contact = compContact.first
    if compContact.present?
      compContact={}
      compContact[:work_phone] = phoneno if phoneno.present?
      compContact[:email] = email if email.present?
      compContact[:country] = country if country.present?
      contact.update_attributes(compContact)
                
      return contact
      
    else
      compContact = CompanyContact.new
      compContact.organization_id= org.id.to_i
      compContact.name = (myname ||=company)
      compContact.email =email
      compContact.country = country
      compContact.work_phone =phoneno
      compContact.website = website
      compContact.created_by =admin
      compContact.time_zone = ActiveSupport::TimeZone[timezoneoffset.to_f].name if timezoneoffset.present?
      if compContact.save
        return compContact
      end
    end
  end
 
 
  def save_individual_contact(name,email,phoneno,country,admin,timezoneoffset, org) 
    invcontact = IndividualContact.where("email =? and organization_id=?", email, org.id)
    contact = invcontact.first
    if invcontact.present?
      individual_contact={}
      individual_contact[:work_phone] = phoneno if phoneno.present?
        if contact.address.present?
            individual_contact[:street]= contact.address.address if contact.address.address.present?
            individual_contact[:city]= contact.address.city if contact.address.city.present?
            individual_contact[:state]= contact.address.state if contact.address.state.present?
            individual_contact[:zip_code]= contact.address.zipcode if contact.address.zipcode.present?
        end
            individual_contact[:email] = email if email.present?
            individual_contact[:country] = country if country.present?
            contact.update_attributes(individual_contact)
                
      return contact
      
    else
      invcontact = IndividualContact.new
      invcontact.organization_id=org.id.to_i
      invcontact.first_name = name
      invcontact.email =email
      invcontact.country = country
      invcontact.work_phone =phoneno
      invcontact.created_by =admin
      invcontact.time_zone = ActiveSupport::TimeZone[timezoneoffset.to_f].name if timezoneoffset.present?
      if invcontact.save
        
        return invcontact
      end
    end
  end 
  def save_bug_report
    p "request ip--------------------======"
    p request

    @report_a_bug = ReportABug.create(email: params[:email], bug_type: params[:bug_type], description: params[:description], ip_address: request.ip)
    redirect_to "/bug_report"
  end
  
end

