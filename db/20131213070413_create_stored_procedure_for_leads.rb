class CreateStoredProcedureForLeads < ActiveRecord::Migration
  def up
    execute <<-__EOI
      
      CREATE PROCEDURE `import_leads_to_deals`(vr_current_user integer)
      BEGIN

          DECLARE vr_id, vr_user_id, vr_assigned_to, v_finished, loop_cntr, num_rows, vr_country_id, cnt_existing_source, vr_company_contact_id, vr_individual_contact_id, vr_label_id INTEGER DEFAULT 0;
          DECLARE vr_created_dt,vr_created_at, vr_updated_at DATETIME;
          DECLARE vr_title, vr_priority, vr_company_name, vr_company_size, vr_website, vr_contact_name, vr_designation, vr_phone,vr_extension, vr_mobile, vr_email, vr_technology, vr_source, vr_location, vr_country, vr_industry, vr_comments,  vr_description, vr_task_type,vr_facebook_url,vr_linkedin_url,vr_twitter_url,vr_skype_id,vr_assigned_user  varchar(255) DEFAULT '';
          DECLARE vr_contact_info varchar(500);
          DECLARE vr_contact_id,vr_won_id,vr_task_type_id,vr_won_deals,vr_task_id, vr_source_id,vr_industry_id,vr_company_strength_id,vr_deal_status_id,vr_deal_id,vr_organization_id,vr_priority_type_id INTEGER default 0;
          DECLARE vr_is_opportunity tinyint;
          declare vr_first_name,vr_last_name varchar(255);
          #-- declare cursor
          DEClARE lead_cursor CURSOR FOR
          select * from temp_leads where user_id = vr_current_user ;
          
          #-- declare NOT FOUND handler
          DECLARE CONTINUE HANDLER
              FOR NOT FOUND SET v_finished = 1;

          OPEN lead_cursor;
          select FOUND_ROWS() into num_rows;
          set v_finished =0;

          select organization_id into vr_organization_id from users  where id = vr_current_user;
          select id into vr_won_id from deal_statuses where organization_id = vr_organization_id and original_id = 4 limit 1;
          
          
          get_lead: LOOP
            set vr_contact_id = 0;
            set vr_company_contact_id =0;
		        set vr_individual_contact_id=0;
	          set vr_source_id=0;
	          set vr_industry_id=0;
	          set vr_phone='';
	          set vr_mobile='';
		        set vr_extension='';
		        set vr_skype_id = '';
		        set vr_company_strength_id = 0;
		        
              FETCH lead_cursor INTO vr_id, vr_user_id, vr_title, vr_priority, vr_company_name, vr_company_size, vr_website, vr_contact_name, vr_designation, vr_phone,vr_extension, vr_mobile, vr_email, vr_technology, vr_source, vr_location, vr_country, vr_industry, vr_comments, vr_created_dt, vr_description, vr_assigned_user,vr_facebook_url,vr_linkedin_url,vr_twitter_url, vr_created_at, vr_updated_at,vr_skype_id,vr_task_type;

              IF v_finished  and loop_cntr =  num_rows THEN

                  LEAVE get_lead;
              END IF;
          select count(deals.id) into cnt_existing_source from deals  inner join notes on notes.notable_id = deals.id and notes.notable_type='Deal'
              where deals.id in( select deal_id from deal_sources where source_id in (select id from sources where name = vr_source))
              and notes.notes = vr_description;
          if(cnt_existing_source = 0) then
          select id into vr_assigned_to from users where email=vr_assigned_user;
          select id into vr_priority_type_id from priority_types where original_id = (case  vr_priority when 'hot' then 1 when 'warm' then 2 when 'cold' then 3 end ) and organization_id = vr_organization_id;

          select id into vr_company_contact_id from company_contacts where name = vr_company_name and organization_id = vr_organization_id limit 1;
           
          if (vr_company_contact_id =0 ) then
            select id into vr_company_strength_id from company_strengths where `range` = replace(replace(vr_company_size,'(',''),')','');
            #insert into contacts (organization_id, name, company_strength_id, contact_type, first_name, last_name, email, website,  linkedin_url, facebook_url, twitter_url, is_public, created_by, created_at, updated_at, is_active, designation)
            #values (vr_organization_id,vr_company_name,vr_company_strength_id,'Company',vr_contact_name,'',vr_email,vr_website,vr_linkedin_url,vr_facebook_url,vr_twitter_url,true,vr_user_id,vr_created_dt,vr_updated_at,true,vr_designation);
	        insert into company_contacts (organization_id,name,company_strength_id,email,website, linkedin_url, facebook_url, twitter_url,created_by, is_public, is_active,  created_at, updated_at)
	        values(vr_organization_id,vr_company_name,vr_company_strength_id,vr_email,vr_website,vr_linkedin_url,vr_facebook_url,vr_twitter_url,vr_user_id,true,true,vr_created_dt,vr_updated_at);
            set vr_company_contact_id =  last_insert_id();
          end if;
	
	      select id into vr_individual_contact_id from individual_contacts where email = vr_email and organization_id = vr_organization_id limit 1;
           
          if (vr_individual_contact_id =0 ) then
            #set vr_first_name =SUBSTRING_INDEX(vr_contact_name, ' ', 1);
            #set vr_last_name =SUBSTRING_INDEX(vr_contact_name, ' ', -1);
            #insert into contacts (organization_id, name, company_strength_id, contact_type, first_name, last_name, email, website,  linkedin_url, facebook_url, twitter_url, is_public, created_by, created_at, updated_at, is_active, designation)
            #values (vr_organization_id,vr_company_name,vr_company_strength_id,'Company',vr_contact_name,'',vr_email,vr_website,vr_linkedin_url,vr_facebook_url,vr_twitter_url,true,vr_user_id,vr_created_dt,vr_updated_at,true,vr_designation);
	        insert into individual_contacts (organization_id,first_name,email,position, linkedin_url, facebook_url, twitter_url,company_contact_id,created_by, is_public, is_active, messanger_type, messanger_id, created_at, updated_at)
	        values(vr_organization_id,vr_contact_name,vr_email,vr_designation,vr_linkedin_url,vr_facebook_url,vr_twitter_url,vr_company_contact_id,vr_user_id,true,true,'Skype',vr_skype_id,vr_created_dt,vr_updated_at);
            set vr_individual_contact_id =  last_insert_id();
          end if;
	
          select id into vr_source_id from sources where name=vr_source and organization_id = vr_organization_id limit 1;
          if (vr_source_id =0) then
            insert into sources ( organization_id, name, created_at, updated_at) values (vr_organization_id,vr_source,curdate(),curdate());
            set vr_source_id=  last_insert_id();

          end if;

          select id into vr_industry_id from industries where name=vr_industry and organization_id = vr_organization_id  limit 1;
          if vr_industry_id =0 then
            insert into industries ( organization_id, name, created_at, updated_at) values (vr_organization_id,vr_industry,curdate(),curdate());
            set vr_industry_id=  last_insert_id();

          end if;
          select id into vr_deal_status_id from deal_statuses where original_id = 1 and organization_id = vr_organization_id  limit 1;
          
       select id into vr_country_id from countries where name=vr_country limit 1;

       select count(*) into vr_won_deals from deals where deal_status_id = vr_won_id and organization_id = vr_organization_id and id IN (select deal_id from deals_contacts where contactable_type = 'IndividualContact' and contactable_id = vr_individual_contact_id );
       
        if (vr_won_deals > 0) then 
         set vr_is_opportunity = 1;
        else 
          set vr_is_opportunity = 0;
        end if;

          insert into deals (organization_id,title,priority_type_id,tags,created_at,updated_at,assigned_to,initiated_by,contact_id,deal_status_id, is_active, is_current,is_csv,is_mail_sent,comments, last_activity_date, country_id, is_opportunity)
            values (vr_organization_id,vr_title,vr_priority_type_id,vr_technology,vr_created_dt,vr_updated_at,vr_assigned_to,vr_user_id,vr_individual_contact_id,vr_deal_status_id, 1, 0, 1, 0,vr_comments,vr_created_dt, vr_country_id,vr_is_opportunity);
            
          set vr_deal_id=  last_insert_id();
	      insert into deals_contacts(organization_id,deal_id,contactable_type,contactable_id,created_at,updated_at)
			      values(vr_organization_id,vr_deal_id,'IndividualContact',vr_individual_contact_id,vr_created_dt,vr_updated_at);
          insert into deal_sources ( organization_id, deal_id, source_id, created_at, updated_at) values(vr_organization_id,vr_deal_id,vr_source_id,curdate(),curdate());
          insert into deal_industries ( organization_id, deal_id, industry_id, created_at, updated_at) values(vr_organization_id,vr_deal_id,vr_industry_id,curdate(),curdate());
          #insert into notes (organization_id,notes,notable_type,notable_id,created_at,updated_at,created_by)
          #    values (vr_organization_id,vr_comments,'Deal',vr_deal_id,curdate(),curdate(),vr_user_id);
          #  insert into notes (organization_id,notes,notable_type,notable_id,created_at,updated_at,created_by)
          #    values (vr_organization_id,vr_description,'Deal',vr_deal_id,curdate(),curdate(),vr_user_id);

         

          insert into addresses (organization_id,country_id, state,addressable_type, addressable_id, created_at, updated_at)
            values(vr_organization_id,vr_country_id, vr_location,'IndividualContact', vr_individual_contact_id, vr_created_dt, vr_updated_at);
          if(vr_phone != '') then
            insert into phones(organization_id, phone_no,extension, phone_type, phoneble_type, phoneble_id, created_at, updated_at)
            values(vr_organization_id, vr_phone,vr_extension, 'work', 'IndividualContact', vr_individual_contact_id, vr_created_dt, vr_updated_at);
          end if;
          if(vr_mobile != '') then
            insert into phones(organization_id, phone_no, phone_type, phoneble_type, phoneble_id, created_at, updated_at)
            values(vr_organization_id, vr_mobile, 'mobile', 'IndividualContact', vr_individual_contact_id, vr_created_dt, vr_updated_at);
          end if;
          
          #SET vr_contact_info = ' {\"name\"=>"+ vr_contact_name +",\"id\"=>"+ vr_individual_contact_id +",\"type\"=> \"individual_contact\",\"phone\"=>"+ vr_mobile +",\"email\"=>"+ vr_email +",\"comp_desg\"=>"+ vr_designation +",\"loc\"=>" + vr_location +"} ';
          
        
        #SET vr_contact_info = "{'name':'"+ IFNULL(vr_contact_name, "")+"','id':'"+IFNULL(vr_individual_contact_id,"")+"','type':'individual_contact','phone':'"+IFNULL(vr_mobile,"")+"','email':'"+IFNULL(vr_email,"")+"','comp_desg':'"+IFNULL(vr_designation,"")+","+IFNULL(vr_company_name,"")+"','loc':'"+IFNULL(vr_location,"")+"'}";
        #SET vr_contact_info = '{"name":"' + IFNULL(vr_contact_name, '') + '","id":"' + IFNULL('10dffdfdfdgf','') + '","type":"individual_contact","phone":"' + IFNULL(vr_mobile,'') + '","email":"' + IFNULL(vr_email,'') + '","comp_desg":"' + IFNULL(vr_designation,'') + ',' + IFNULL(vr_company_name,'') + '","loc":"' + IFNULL(vr_location,'') + '"}';
         SET vr_contact_info = CONCAT('{"name":"' ,IFNULL(vr_contact_name, '') ,'","id":"' ,IFNULL(vr_individual_contact_id,'') ,'","type":"individual_contact","phone":"' ,IFNULL(vr_phone,'') ,'","email":"' ,IFNULL(vr_email,'') ,'","comp_desg":"' ,IFNULL(vr_designation,'') ,',' ,IFNULL(vr_company_name,'') ,'","loc":"' ,IFNULL(vr_location,'') ,'"}');
          
          update deals set contact_info = vr_contact_info where id=vr_deal_id;
          
          select id into vr_task_type_id from task_types where name = vr_task_type and organization_id = vr_organization_id limit 1;
          
          insert into tasks (organization_id,title, task_type_id,assigned_to, priority_id, deal_id,due_date,created_at, updated_at,taskable_id,taskable_type,created_by,is_completed,recurring_type)
            values(vr_organization_id,vr_task_type, vr_task_type_id,vr_assigned_to,1, vr_deal_id,vr_created_dt+INTERVAL 1 DAY,vr_created_dt, vr_updated_at,vr_deal_id,'Deal',vr_user_id, 0, 'none');
            
          set vr_task_id=  last_insert_id();
          update tasks set parent_id = vr_task_id where id=vr_task_id;
          
          update deals set latest_task_type_id = vr_task_type_id where id=vr_deal_id;
          
          insert into activities (organization_id,activity_type,activity_id,activity_user_id,activity_status,activity_desc,activity_date,is_public,created_at,updated_at,source_id)
            values(vr_organization_id,'Task',vr_task_id,vr_user_id,'Create',vr_task_type,vr_created_dt,1,vr_created_dt,vr_created_dt,vr_deal_id);
          
           insert into activities (organization_id,activity_type,activity_id,activity_user_id,activity_status,activity_desc,activity_date,is_public,created_at,updated_at,source_id)
            values(vr_organization_id,'Task',vr_task_id,vr_assigned_to,'Assign',vr_task_type,vr_created_dt,1,vr_created_dt,vr_created_dt,vr_deal_id);
          
          
          select id into vr_label_id from user_labels where organization_id=vr_organization_id and name = 'outbound' limit 1;
          if (vr_label_id =0) then
            insert into user_labels ( organization_id, user_id,name, color,created_at, updated_at) values (vr_organization_id,vr_user_id,'Outbound','#a321c4',curdate(),curdate());
            set vr_label_id =  last_insert_id();
          end if;
          insert into deal_labels ( organization_id, deal_id,user_label_id,created_at, updated_at) values (vr_organization_id,vr_deal_id,vr_label_id,curdate(),curdate());
          
          
           if(vr_technology is not null and trim(vr_technology) != '') then
                call split (vr_technology, ',');
                update tags set taggings_count =  taggings_count +1 where name  in ( select item from Tempsplitvalues);
                insert into tags (name, taggings_count) 
                select item,1 from Tempsplitvalues where item not in (select name from tags);
                insert into taggings (tag_id,taggable_id,taggable_type,context,created_at,tagger_id,tagger_type)
      select id, vr_deal_id, 'Deal','tags',curdate(),vr_organization_id,'Organization'  from tags where name in (select item from Tempsplitvalues);
                truncate table Tempsplitvalues;
            end if;
        end if;
          SET loop_cntr = loop_cntr + 1;

          END LOOP get_lead;

          CLOSE lead_cursor;
          delete from temp_leads where user_id = vr_current_user ;
      END

    __EOI
  end
  

  def down
    execute <<-__EOI
      DROP PROCEDURE IF EXISTS `import_leads_to_deals`;
    __EOI
  end
  
end
