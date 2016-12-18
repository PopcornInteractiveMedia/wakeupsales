SalesCafe::Application.routes.draw do
  #require 'sidekiq/web'

  get 'home/index'
  match 'users/sign_up' => 'home#index', :via => [:get]
  #devise_for :users, :controllers => {:registrations => 'registrations'}
  devise_for :users, :controllers => {:registrations => "registrations", :omniauth_callbacks => "omniauth_callbacks",:passwords => "passwords"}
  

  match "/contacts/:importer/contact_callback" => 'contacts#contact_callback', :via => [:get, :post]
  match 'import_contacts' => 'contacts#import_contacts', :via => [:get, :post]

  match '/contacts/failure' => 'contacts#import_failure'
  resources :settings
  post 'settings/save_group' => 'settings#save_group'
  post 'settings/delete_group' => 'settings#delete_group'
  post 'settings/delete_label' => 'settings#delete_label'
  post 'settings/get_group' => 'settings#get_group'
  post 'settings/save_source' => 'settings#save_source', :as => 'save_source'
  post 'settings/save_industry' => 'settings#save_industry', :as => 'save_industry'
  post 'settings/save_label' => 'settings#save_label', :as => 'save_label'
  post 'settings/save_user_label' => 'settings#save_user_label', :as => 'save_label'
  post 'settings/get_user_label' => 'settings#get_user_label'
  post 'settings/get_task_outcome_label' => 'settings#get_task_outcome_label'
  post 'settings/save_task_outcome_label' => 'settings#save_task_outcome_label'
  post 'settings/delete_taskoutcome' => 'settings#delete_taskoutcome'

  match '/update_weekly_digest' => 'settings#update_weekly_digest', :via => [:get, :post]
  match '/unscribe_latest_blog' => 'settings#unscribe_latest_blog', :via => [:get, :post]
  match 'settings/update_priority_org' => 'settings#update_priority_org', :via => [:get, :post]
  match 'settings/update_lead_status' => 'settings#update_deal_status', :via => [:get, :post]
  match 'settings/update_feed_keyword_org' => 'settings#update_feed_keyword_org', :via => [:get, :post]
  match 'settings/update_widget_org' => 'settings#update_widget_org', :via => [:get, :post]
  match 'settings/update_notification' => 'settings#update_notification', :via => [:get, :post]
  match 'settings/fetch_pages' => 'settings#fetch_pages', :via => [:get, :post]
  match 'update_org_settings' => 'settings#update_org_settings'
  match 'get_contacts/:org_id' => 'application#get_contacts'
  match 'settings/edit_source' => 'settings#edit_source'
  match 'settings/edit_industry' => 'settings#edit_industry'
  match 'edit_company_contact/:id' => 'contacts#edit_company_contact'
  match 'edit_individual_contact/:id' => 'contacts#edit_individual_contact'
  match 'getting_started' => 'home#getting_started'
  match 'clear_cache' => 'home#clear_cache'
  match 'load_header_count_section' => 'home#load_header_count_section'
  match 'pie_donut_chart' => 'home#pie_donut_chart'
  match 'line_chart_display' => 'home#line_chart_display'
  match 'summary' => 'home#summary'
  match 'lead_statistics_info' => 'home#deal_statistics_info'
  match 'pie_chart_display' => 'home#pie_chart_display'
  match 'task_widget_page' => 'home#task_widget_page'
  match 'header_user_info' => 'application#header_user_info'
  match 'load_all_partials' => 'application#load_all_partials'
  match 'lead_contacts_info' => 'deals#deal_contacts_info'
  match 'created_by_user' => 'deals#created_by_user'
  match 'lead_location_filter' => 'deals#deal_location_filter'
  match 'assigned_lead_leaderboard' => 'deals#assigned_deal_leaderboard'
  match 'upload_multiple_note_attach' => 'deals#upload_multiple_note_attach'
  match 'delete_temp_note_attach' => 'deals#delete_temp_note_attach'
  match 'send_weekly_digest_email' => 'deals#send_weekly_digest_email'

  authenticated :user do
    root :to => 'home#dashboard'
  end
  devise_scope :user do
    root :to => 'devise/sessions#new'
  end
  match '/notfound' => 'home#notfound'

  #match '/pricing' => 'home#pricing'
  match '/pricing' => 'home#index'
  match '/terms' => 'home#terms'
  match '/privacy' => 'home#privacy'
  match '/security' => 'home#security'
  match '/contact_us' => 'home#contact_us'
  match '/activities' => 'home#activities'
  match '/api_contact_us' => 'home#api_contact_us', :via => [:post]
  match '/bug_report' => 'home#report_a_bug'
  match '/save_bug_report' => 'api#save_bug_report', :via => [:post]
  match '/show_bug_report/:id' => 'home#show_bug_report'
  match '/post_comment' => 'home#post_comment'
  


  get 'dashboard' => 'home#dashboard', :as => 'dashboard'
  match '/task_widget' => 'home#task_widget'
  match '/lead_task_widget' => 'deals#deal_task_widget'
  match '/task_widget_reload' => 'deals#task_widget_reload'
  match '/get_activities' => 'home#get_activities'
  match '/usage' => 'home#usage'
  resources :contacts do
    get :autocomplete_first_name, :on => :collection

  end

  match 'add_contact_form' => 'contacts#add_contact_form', :via => [:post]
  match 'get_companies/:org_id' => 'application#get_companies'
  match 'company_contact/:id' => 'contacts#company_contact_detail'
  match 'individual_contact/:id' => 'contacts#individual_contact_detail'
  match 'contact/:id' => 'contacts#show_contact_detail'
  resources :contacts
  match 'contacts/change_status/:id' => 'contacts#change_status', :via => [:post]
  match 'get_all_contacts' => 'contacts#get_all_contacts', :via => [:GET]
  match 'get_more_contacts' => 'contacts#get_more_contacts', :via => [:post], :as => 'get_more_contacts'
  match 'contact_widget' => 'contacts#contact_widget', :via => [:post]
  match 'get_contact_ajax' => 'contacts#get_contact_ajax', :via => [:post]
  match 'save_contact_timezone' => 'contacts#save_contact_timezone'

  match 'imported_contacts' => 'contacts#imported_contacts', :via => [:get,:post] 
  match 'import_contact_from_sugar_crm' => 'contacts#import_contact_from_sugar_crm', :via => [:get,:post] 
  match 'import_contact_from_zoho_crm' => 'contacts#import_contact_from_zoho_crm', :via => [:get,:post] 
  match 'import_contact_from_fatfree_crm' => 'contacts#import_contact_from_fatfree_crm', :via => [:get,:post] 
  match 'import_contact_from_other_crm' => 'contacts#import_contact_from_other_crm', :via => [:get,:post] 
  match 'proceed_to_lead' => 'contacts#proceed_to_lead', :via => [:get] 

  
  resources :users
  match 'get_user_email' => 'users#get_user_email'
  match 'profile' => 'users#profile'
  match 'profile/:id' => 'users#profile'
  match '/create_admin_user' => 'users#create_admin_user', :via => [:post]

  match '/download_user' => 'home#download_user', :as => 'download_user'
  match 'source_list' => 'users#source_list', :as => 'source_list'
  match 'industry_list' => 'users#industry_list', :as => 'industry_list'
  match '/change_password' => 'users#change_password'
  match '/save_password' => 'users#save_password', :via => [:put]
  match 'invite_user' => 'users#invite_user'
  match 'get_source_list' => 'users#get_source_list', :via => [:post], :as => 'get_source_list'
  match 'get_industry_list' => 'users#get_industry_list', :via => [:post], :as => 'get_industry_list'
  match 'delete_source/:id' => 'users#delete_source'
  match 'delete_industry/:id' => 'users#delete_industry'
  match 'save_profile_info' => 'users#save_profile_info'
  match 'edit_user' => 'users#edit_user'
  match 'resend_invitation' => 'users#resend_invitation'
  match 'load_header_count_user' => 'users#load_header_count_user'
  match 'enable_user/:id' => 'users#enable_usr'
  match 'user_save_tmp_img' => 'users#save_tmp_img'
  match 'update_profile_image' => 'users#update_profile_image'

  resources :tasks
  match 'calendar_task' => 'tasks#calendar_task'
  match 'calendar_data' => 'tasks#calendar_data'
  match 'task_tab_data' => 'tasks#task_tab_data'

  match 'complete' => 'tasks#complete', :via => [:post]
  match 'edit_task' => 'tasks#edit_task'
  match 'follow_up_task' => 'tasks#follow_up_task'
  match 'start_task' => 'tasks#start_task', :via => [:post]
  match 'all_task' => 'tasks#all_task', :via => [:post]
  match 'today_task' => 'tasks#today_task', :via => [:post]
  match 'overdue_task' => 'tasks#overdue_task', :via => [:post]
  match 'upcoming_task' => 'tasks#upcoming_task', :via => [:post]
  match 'task_listing' => 'tasks#task_listing', :via => [:post]
  match 'task_filter' => 'tasks#task_filter', :via => [:post]

  match '/get_sqllite_task' => 'tasks#get_sqllite_task'
  match 'get_inactive_leads' => 'deals#get_inactive_deals'
  resources :deals, path: :leads, as: :leads
  match 'leads/move_lead' => 'deals#move_deal', :via => [:post], :as => 'move_lead'
  match 'leads/apply_label_to_lead' => 'deals#apply_label_to_deal', :via => [:post]
  match 'leads/apply_label_to_single_lead' => 'deals#apply_label_to_single_deal', :via => [:post]
  match 'leads/setting' => 'deals#deal_setting', :via => [:post]
  match 'get_incoming_leads' => 'deals#get_incoming_deals', :via => [:post], :as => 'get_incoming_leads'
  match 'get_working_on_leads' => 'deals#get_working_on_deals', :via => [:post], :as => 'get_working_on_leads'
  match 'get_won_leads' => 'deals#get_won_deals', :via => [:post], :as => 'get_won_leads'
  match 'get_lost_leads' => 'deals#get_lost_deals', :via => [:post], :as => 'get_lost_leads'
  match 'get_junk_leads' => 'deals#get_junk_deals', :via => [:post], :as => 'get_junk_leads'
  match 'get_un_assigned_leads' => 'deals#get_un_assigned_deals', :via => [:post], :as => 'get_un_assigned_leads'
  match 'get_other_leads' => 'deals#get_other_deals', :via => [:post], :as => 'get_other_leads'

  match 'get_contact' => 'deals#get_contact', :via => [:post]
  match 'edit_lead' => 'deals#edit_deal', :via => [:post]
  match 'delete_selected_leads' => 'deals#delete_selected_deals'
  match 'get_qualify_leads' => 'deals#get_qualify_deals', :via => [:post], :as => 'get_qualify_leads'
  match 'get_not_qualify_leads' => 'deals#get_not_qualify_deals', :via => [:post], :as => 'get_not_qualify_leads'
  match 'get_leads/:org_id' => 'application#get_deals'
  match 'learnmore' => 'deals#learnmore'
  match 'add_contact' => 'deals#add_contact'
  match 'delete_lead_con/:id' => 'deals#delete_deal_con'
  match 'update_lead_ttl' => 'deals#update_deal_ttl'
  match 'update_note_ttl' => 'deals#update_note_ttl'
  match 'fetch_activity' => 'deals#fetch_activity'
  match 'fetch_user_leads' => 'deals#fetch_user_deals'
  match 'get_industry_list' => 'deals#get_industry_list'
  match 'save_lead_industry' => 'deals#save_deal_industry'
  match 'get_country_list' => 'deals#get_country_list', :as => 'get_country_list'
  match 'save_country_lead' => 'deals#save_country_lead', :as => 'save_country_lead'
  match 'get_user_list_lead' => 'deals#get_user_list_lead', :as => 'get_user_list_lead'
  match 'save_user_lead' => 'deals#save_user_lead', :as => 'save_user_lead'
  match 'save_compsize_lead' => 'deals#save_compsize_lead', :as => 'save_compsize_lead'
  match 'quick_lead' => 'deals#quick_deal'
  match 'change_assigned_to' => 'deals#change_assigned_to', :as => 'change_assigned_to'
  match 'get_task_type_lead' => 'deals#get_task_type_lead', :as => 'get_task_type_lead'
  match 'save_task_type_lead' => 'deals#save_task_type_lead', :as => 'save_task_type_lead'
  match 'accept_lead' => 'deals#accept_assign_deal'
  match 'deny_lead' => 'deals#deny_assign_deal'

  match 'leads_woking_on/:id' => 'deals#deals_woking_on', :via => [:post]
  match 'bulk_lead_upload' => 'deals#bulk_lead_upload', :via => [:post]
  match 'lead_preview' => 'deals#lead_preview', :via => [:get, :post], :except => [:show]
  match 'destroy_lead' => 'deals#destroy_all_lead'
  match 'save_lead' => 'deals#save_lead'
  match 'save_lead_phone' => 'deals#save_lead_phone'
  match 'save_lead_email' => 'deals#save_lead_email'
  match 'save_lead_data' => 'deals#save_lead_data'
  match '/edit_note' => 'deals#edit_note'
  match '/delete_note_attachment/:id' => 'deals#delete_note_attachment'
  match '/lead_files' => 'deals#deal_files'
  match '/lead_detail_contacts' => 'deals#deal_detail_contacts'
  match 'reassign_user_to_deals' => 'deals#reassign_user_to_deals'
  match '/hide_note' => 'deals#hide_note'

  match 'search_result' => 'search#show'
  resources :search

  match 'fetch_notification_count' => 'home#fetch_notification_count'

  # resources :contacts, :except => :show do
  #  collection do
  #    get :add_notes
  #    post :add_notes
  #  end
  # end


  # match 'contacts/add_notes'=>'contacts#add_notes', :via => [:get,:post]


  match 'add_notes' => 'application#add_notes', :via => [:post]
  match 'send_email' => 'contacts#send_email', :via => [:get, :post]
  match 'get_extension' => 'application#get_extension'
  match 'get_country_states' => 'application#get_country_states'
  match 'attention_notification' => 'application#attention_notification'
  match 'render_notification_area' => 'application#render_notification_area'

  resources :reports
  match 'get_funnel_chart' => 'reports#get_funnel_chart'
  match 'get_user_list_leaderboard' => 'reports#get_user_list_leaderboard'
  match 'get_leads_won' => 'reports#get_deals_won'
  match 'pie_tag_chart' => 'reports#pie_tag_chart'
  match 'report_pdf' => 'reports#report_pdf'
  match 'get_sales_analytic' => 'reports#get_sales_analytic'
  match 'get_lead_report' => 'reports#get_lead_report'
  match 'lead_age_bar_chart' => 'reports#lead_age_bar_chart'

  resources :beta_accounts
  match 'bconfirm' => 'beta_accounts#verify_user'
  match 'approve/:buser_id' => 'beta_accounts#approve'
  match 'disapprove/:buser_id' => 'beta_accounts#disapprove'
  match 'bsignup' => 'home#index'

  #API routes
  match 'api/createLead' => 'api#createLead', :via => [:post]
  match '/send_latest_blog_mail' => 'home#send_latest_blog_mail', :via => [:get, :post]
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with 'root'
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with 'rake routes'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  match ':rest' => 'application#page_not_found_error', :constraints => { :rest => /.*/ }
  # match 'contact_callback' => 'contacts#contact_callback'
  match 'import_contacts' => 'contacts#import_contacts'
  match 'testgmail' => 'contacts#testgmail' #,:via=>[:post]
  # match '/contacts/:importer/callback' => 'contacts#callback'
  # match 'contacts/:provider/contact_callback' => 'contacts#contact_callback'
  # match 'contacts/invite_contacts' =>'contacts#invite_contacts'
  # mount Sidekiq::Web, at: '/sidekiq'

end
