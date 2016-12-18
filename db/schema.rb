# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20161202071258) do

  create_table "Tempsplitvalues", :force => true do |t|
    t.string "item"
  end

  create_table "activities", :force => true do |t|
    t.integer  "organization_id"
    t.string   "activity_type"
    t.integer  "activity_id"
    t.integer  "activity_user_id"
    t.string   "activity_status"
    t.string   "activity_desc"
    t.datetime "activity_date"
    t.boolean  "is_public",        :default => true,  :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "source_id"
    t.boolean  "is_available",     :default => false
    t.integer  "activity_by"
  end

  add_index "activities", ["activity_date"], :name => "index_activities_on_activity_date"
  add_index "activities", ["activity_user_id"], :name => "index_activities_on_activity_user_id"
  add_index "activities", ["organization_id"], :name => "index_activities_on_organization_id"
  add_index "activities", ["source_id"], :name => "index_activities_on_source_id"

  create_table "activities_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "activity_id"
    t.string   "contactable_type"
    t.integer  "contactable_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "addresses", :force => true do |t|
    t.integer  "organization_id"
    t.string   "address_type"
    t.text     "address"
    t.integer  "country_id"
    t.string   "state"
    t.string   "city"
    t.string   "zipcode"
    t.string   "addressable_type"
    t.integer  "addressable_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "indivisual_contact_id"
  end

  add_index "addresses", ["country_id"], :name => "index_addresses_on_country_id"
  add_index "addresses", ["organization_id"], :name => "index_addresses_on_organization_id"

  create_table "attention_deals", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.text     "deal_ids"
    t.integer  "deal_count"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "beta_accounts", :force => true do |t|
    t.string   "email"
    t.text     "invitation_token"
    t.integer  "invited_by"
    t.boolean  "is_verified",          :default => false
    t.boolean  "is_approved",          :default => false
    t.boolean  "is_registered",        :default => false
    t.boolean  "is_siteadmin_invited", :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "email",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "report_a_bug_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["report_a_bug_id"], :name => "index_comments_on_report_a_bug_id"

  create_table "company_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "company_strength_id"
    t.string   "email"
    t.string   "messanger_type"
    t.string   "messanger_id"
    t.string   "website"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.integer  "created_by"
    t.boolean  "is_public",           :default => true, :null => false
    t.boolean  "is_active",           :default => true, :null => false
    t.integer  "contact_ref_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "time_zone"
  end

  create_table "company_strengths", :force => true do |t|
    t.string   "range"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contact_us", :force => true do |t|
    t.string   "email"
    t.boolean  "is_remote",  :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "contact_us_infos", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.string   "phone"
    t.integer  "contact_us_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "contact_us_infos", ["contact_us_id"], :name => "index_contact_us_infos_on_contact_us_id"

  create_table "contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "company_strength_id"
    t.string   "contact_type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "website"
    t.string   "messanger_type"
    t.string   "messanger_id"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.boolean  "is_public"
    t.integer  "created_by"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_active",           :default => true
  end

  add_index "contacts", ["company_strength_id"], :name => "index_contacts_on_company_strength_id"
  add_index "contacts", ["organization_id"], :name => "index_contacts_on_organization_id"

  create_table "countries", :force => true do |t|
    t.string "ccode"
    t.string "name"
    t.string "isd_code"
    t.string "flag"
  end

  create_table "deal_industries", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "industry_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_industries", ["deal_id"], :name => "index_deal_industries_on_deal_id"
  add_index "deal_industries", ["industry_id"], :name => "index_deal_industries_on_industry_id"
  add_index "deal_industries", ["organization_id"], :name => "index_deal_industries_on_organization_id"

  create_table "deal_labels", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "user_label_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_labels", ["deal_id"], :name => "index_deal_labels_on_deal_id"
  add_index "deal_labels", ["organization_id"], :name => "index_deal_labels_on_organization_id"
  add_index "deal_labels", ["user_label_id"], :name => "index_deal_labels_on_user_label_id"

  create_table "deal_moves", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "deal_status_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_moves", ["deal_id"], :name => "index_deal_moves_on_deal_id"
  add_index "deal_moves", ["deal_status_id"], :name => "index_deal_moves_on_deal_status_id"
  add_index "deal_moves", ["organization_id"], :name => "index_deal_moves_on_organization_id"
  add_index "deal_moves", ["user_id"], :name => "index_deal_moves_on_user_id"

  create_table "deal_settings", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "tabs"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_settings", ["organization_id"], :name => "index_deal_settings_on_organization_id"
  add_index "deal_settings", ["user_id"], :name => "index_deal_settings_on_user_id"

  create_table "deal_sources", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "source_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_sources", ["deal_id"], :name => "index_deal_sources_on_deal_id"
  add_index "deal_sources", ["organization_id"], :name => "index_deal_sources_on_organization_id"
  add_index "deal_sources", ["source_id"], :name => "index_deal_sources_on_source_id"

  create_table "deal_statuses", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "original_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_statuses", ["organization_id"], :name => "index_deal_statuses_on_organization_id"

  create_table "deals", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.integer  "priority_type_id"
    t.integer  "assigned_to"
    t.integer  "contact_id"
    t.string   "tags"
    t.float    "amount"
    t.integer  "probability"
    t.integer  "attempts"
    t.boolean  "is_public",             :default => true
    t.integer  "initiated_by"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "deal_status_id"
    t.boolean  "is_active"
    t.boolean  "is_current"
    t.integer  "country_id"
    t.boolean  "is_csv",                :default => false
    t.boolean  "is_mail_sent",          :default => true
    t.integer  "closed_by"
    t.datetime "last_activity_date"
    t.text     "comments"
    t.boolean  "is_remote",             :default => false
    t.string   "app_type"
    t.integer  "latest_task_type_id"
    t.text     "contact_info"
    t.datetime "stage_move_date"
    t.string   "duration"
    t.string   "billing_type"
    t.boolean  "is_opportunity",        :default => false,      :null => false
    t.string   "payment_status",        :default => "Not done"
    t.string   "referrer"
    t.text     "hot_lead_token"
    t.datetime "token_expiry_time"
    t.integer  "next_priority_id"
    t.integer  "assignee_id"
    t.text     "visited"
    t.text     "location_by_api"
    t.integer  "individual_contact_id"
  end

  add_index "deals", ["organization_id"], :name => "index_deals_on_organization_id"
  add_index "deals", ["priority_type_id"], :name => "index_deals_on_priority_type_id"

  create_table "deals_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.string   "contactable_type"
    t.integer  "contactable_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "download_users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "email_notifications", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "due_task"
    t.boolean  "task_assign"
    t.boolean  "deal_assign"
    t.boolean  "donot_send"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "feed_keywords", :force => true do |t|
    t.integer  "organization_id"
    t.string   "feed_tags"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "feed_keywords", ["organization_id"], :name => "index_feed_keywords_on_organization_id"

  create_table "images", :force => true do |t|
    t.integer  "organization_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "imagable_type"
    t.integer  "imagable_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "images", ["organization_id"], :name => "index_images_on_organization_id"

  create_table "individual_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "position"
    t.string   "messanger_type"
    t.string   "messanger_id"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.integer  "company_contact_id"
    t.integer  "created_by"
    t.boolean  "is_public",           :default => true,  :null => false
    t.boolean  "is_active",           :default => true,  :null => false
    t.integer  "contact_ref_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "time_zone"
    t.boolean  "is_customer",         :default => false, :null => false
    t.boolean  "subscribe_blog_mail", :default => true,  :null => false
    t.datetime "subscribe_blog_date"
    t.string   "website"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "company_name"
    t.string   "work_phone"
    t.text     "description"
  end

  create_table "industries", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "industries", ["organization_id"], :name => "index_industries_on_organization_id"

  create_table "mail_letters", :force => true do |t|
    t.integer  "organization_id"
    t.string   "mailable_type"
    t.integer  "mailable_id"
    t.string   "mailto"
    t.string   "subject"
    t.text     "description"
    t.integer  "mail_by"
    t.string   "mail_cc"
    t.string   "mail_bcc"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "contact_info"
  end

  add_index "mail_letters", ["organization_id"], :name => "index_mail_letters_on_organization_id"

  create_table "note_attachments", :force => true do |t|
    t.integer  "note_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "note_attachments", ["note_id"], :name => "index_note_attachments_on_note_id"

  create_table "notes", :force => true do |t|
    t.integer  "organization_id"
    t.text     "notes"
    t.string   "file_description"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string   "notable_type"
    t.integer  "notable_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "created_by"
    t.boolean  "is_public",               :default => false
  end

  add_index "notes", ["organization_id"], :name => "index_notes_on_organization_id"

  create_table "opportunities", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "quarter"
    t.integer  "total_deals"
    t.integer  "won_deals"
    t.float    "win"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "website"
    t.integer  "total_users"
    t.integer  "size_id"
    t.boolean  "is_premium"
    t.boolean  "is_active"
    t.datetime "deleted_at"
    t.integer  "beta_account_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "auth_token"
    t.text     "description"
  end

  create_table "payment_infos", :force => true do |t|
    t.integer  "organization_id"
    t.string   "transaction_id"
    t.float    "amount"
    t.datetime "transaction_date"
    t.string   "last4_digit"
    t.string   "customer_id"
    t.string   "card_holder_name"
    t.string   "street"
    t.string   "city"
    t.string   "country"
    t.string   "zipcode"
    t.string   "payment_token"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "payment_infos", ["organization_id"], :name => "index_payment_infos_on_organization_id"

  create_table "phones", :force => true do |t|
    t.integer  "organization_id"
    t.string   "phone_no"
    t.string   "extension"
    t.string   "phone_type"
    t.string   "phoneble_type"
    t.integer  "phoneble_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "phones", ["organization_id"], :name => "index_phones_on_organization_id"

  create_table "priority_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "original_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "priority_types", ["organization_id"], :name => "index_priority_types_on_organization_id"

  create_table "report_a_bugs", :force => true do |t|
    t.string   "email"
    t.string   "bug_type"
    t.text     "description"
    t.string   "bug_status",  :default => "New"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "ip_address"
    t.string   "country"
  end

  create_table "roles", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "roles", ["organization_id"], :name => "index_roles_on_organization_id"

  create_table "sales_cycles", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "quarter"
    t.integer  "average"
    t.integer  "shortest"
    t.integer  "longest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "sent_email_opens", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.string   "opened"
    t.integer  "activity_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sent_emails", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "sent"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sources", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "sources", ["organization_id"], :name => "index_sources_on_organization_id"

  create_table "subscribe_blog_logs", :force => true do |t|
    t.integer  "contact_id"
    t.string   "contact_email"
    t.text     "blog_title"
    t.text     "blog_content"
    t.string   "status"
    t.string   "error_message"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "task_outcomes", :force => true do |t|
    t.string   "name"
    t.string   "task_out_type"
    t.string   "task_duration"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "task_priority_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "original_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "task_priority_types", ["organization_id"], :name => "index_task_priority_types_on_organization_id"

  create_table "task_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "task_types", ["organization_id"], :name => "index_task_types_on_organization_id"

  create_table "tasks", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.integer  "task_type_id"
    t.integer  "assigned_to"
    t.integer  "priority_id"
    t.integer  "deal_id"
    t.datetime "due_date"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "mail_to"
    t.integer  "taskable_id"
    t.string   "taskable_type"
    t.integer  "created_by"
    t.boolean  "is_completed",    :default => false,  :null => false
    t.text     "task_note"
    t.string   "recurring_type",  :default => "none", :null => false
    t.datetime "rec_end_date"
    t.integer  "parent_id"
    t.boolean  "is_event",        :default => false,  :null => false
    t.datetime "event_end_date"
  end

  add_index "tasks", ["organization_id"], :name => "index_tasks_on_organization_id"
  add_index "tasks", ["task_type_id"], :name => "index_tasks_on_task_type_id"

  create_table "temp_contacts", :force => true do |t|
    t.integer  "import_by"
    t.string   "domain"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name"
    t.string   "gender"
    t.string   "birthday"
    t.string   "relation"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "postcode"
    t.string   "phone_number"
    t.string   "profile_picture"
    t.string   "updated"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "company_name"
    t.string   "website"
  end

  create_table "temp_file_uploads", :force => true do |t|
    t.integer  "user_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "temp_images", :force => true do |t|
    t.integer  "user_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "temp_images", ["user_id"], :name => "index_temp_images_on_user_id"

  create_table "temp_leads", :force => true do |t|
    t.integer  "user_id"
    t.text     "title"
    t.string   "priority"
    t.string   "company_name"
    t.string   "company_size"
    t.string   "website"
    t.string   "contact_name"
    t.string   "designation"
    t.string   "phone"
    t.string   "extension"
    t.string   "mobile"
    t.string   "email"
    t.string   "technology"
    t.text     "source"
    t.string   "location"
    t.string   "country"
    t.string   "industry"
    t.text     "comments"
    t.datetime "created_dt"
    t.text     "description"
    t.string   "assigned_to"
    t.string   "facebook_url"
    t.string   "linkedin_url"
    t.string   "twitter_url"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "skype_id"
    t.string   "task_type"
  end

  create_table "temp_tables", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "phone"
    t.string   "title"
    t.string   "company_name"
    t.string   "web_site"
    t.text     "address"
    t.string   "ref_site"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "country"
    t.integer  "user_id"
  end

  create_table "user_labels", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "color"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_labels", ["organization_id"], :name => "index_user_labels_on_organization_id"
  add_index "user_labels", ["user_id"], :name => "index_user_labels_on_user_id"

  create_table "user_preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "weekly_digest",         :default => true,     :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "digest_mail_frequency", :default => "weekly"
  end

  add_index "user_preferences", ["user_id"], :name => "index_user_preferences_on_user_id"

  create_table "user_roles", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_roles", ["organization_id"], :name => "index_user_roles_on_organization_id"
  add_index "user_roles", ["role_id"], :name => "index_user_roles_on_role_id"

  create_table "users", :force => true do |t|
    t.integer  "organization_id"
    t.string   "email",                  :default => "",   :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role_id"
    t.integer  "target"
    t.integer  "admin_type"
    t.string   "encrypted_password",     :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,    :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0,    :null => false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "time_zone"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.boolean  "is_active",              :default => true
    t.datetime "task_date"
    t.string   "digest_mail_date"
    t.integer  "priority_label",         :default => 0,    :null => false
    t.string   "token"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token", :unique => true
  add_index "users", ["organization_id"], :name => "index_users_on_organization_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "widgets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "chart",            :default => true
    t.boolean  "activities",       :default => true
    t.boolean  "feeds",            :default => true
    t.boolean  "tasks",            :default => true
    t.boolean  "usage",            :default => true
    t.boolean  "summary",          :default => true
    t.boolean  "pie_chart",        :default => true
    t.boolean  "column_chart",     :default => true
    t.boolean  "line_chart",       :default => true
    t.boolean  "statistics_chart", :default => true
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "widgets", ["user_id"], :name => "index_widgets_on_user_id"

end
