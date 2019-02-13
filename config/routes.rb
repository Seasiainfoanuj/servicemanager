ServiceManager::Application.routes.draw do

  root :to => 'dashboard#index'
  devise_for :users, path_names: {sign_in: 'login', sign_out: 'logout'}

  get 'dashboard', to: 'dashboard#index'
  get 'changelog', to: 'dashboard#changelog'

  get 'user_guides', to: 'user_guides#index'
  get 'user_guides/index', to: 'user_guides#index'
  get 'user_guides/terms', to: 'user_guides#terms'
  get 'user_guides/:page', to: 'user_guides#show'

  get 'privacy_statement', to: 'dashboard#privacy_statement'
  get 'activities' => 'activities#index', defaults: { format: 'json' }, constraints: { format: 'json' }

  get 'mailgun/log', to: 'mailgun#log'
  get 'mailgun/bounces', to: 'mailgun#bounces'

  # Clients
  resources :clients, except: [:new, :create] do
    patch 'create_person', on: :member
    patch 'create_company', on: :member
  end

  resources :contact_role_types
  resources :hire_product_types

  # Users
  resources :users do
    get 'admin', on: :new
    get 'supplier', on: :new
    get 'service_provider', on: :new
    get 'customer', on: :new
    get 'quote_customer', on: :new
    get 'employee', on: :new
    get 'masteradmin', on: :new
    get 'superadmin', on: :new
    get 'dealer', on: :new
    get 'edit_company_profile', on: :member
    get 'show_company_profile', on: :member
    patch 'update_company_profile', on: :member
    post 'add_contact_role', on: :member
    patch 'remove_contact_role', on: :member
  end

  resources :companies do
    post 'add_contact', on: :member
  end

  resources :addresses

  # avoid overriding :user_id
  get '/users/:filtered_user_id/build_orders/' => 'build_orders#index', as: 'user_build_orders'
  get '/users/:filtered_user_id/builds/' => 'builds#index', as: 'user_builds'
  get '/users/:filtered_user_id/enquiries/' => 'enquiries#index', as: 'user_enquiries'
  get '/users/:filtered_user_id/hire_agreements/' => 'hire_agreements#index', as: 'user_hire_agreements'
  get '/users/:filtered_user_id/off_hire_jobs/' => 'off_hire_jobs#index', as: 'user_off_hire_jobs'
  get '/users/:filtered_user_id/quotes/' => 'quotes#index', as: 'user_quotes'
  get '/users/:filtered_user_id/po_requests/' => 'po_requests#index', as: 'user_po_requests'
  get '/users/:filtered_user_id/stock_requests/' => 'stock_requests#index', as: 'user_stock_requests'
  get '/users/:filtered_user_id/stocks/' => 'stocks#index', as: 'user_stocks'
  get '/users/:filtered_user_id/vehicle_logs/' => 'vehicle_logs#index', as: 'user_vehicle_logs'
  get '/users/:filtered_user_id/vehicles/' => 'vehicles#index', as: 'user_vehicles'
  get '/users/:filtered_user_id/vehicle_contracts/' => 'vehicle_contracts#index', as: 'user_vehicle_contracts'
  get '/users/:filtered_user_id/workorders/' => 'workorders#index', as: 'user_workorders'

  get 'administrators' => 'users#administrators'
  get 'suppliers' => 'users#suppliers'
  get 'service_providers' => 'users#service_providers'
  get 'customers' => 'users#customers'
  get 'quote_customers' => 'users#quote_customers'
  get 'employees' => 'users#employees'
  get 'masteradmins' => 'users#masteradmins'
  get 'superadmins' => 'users#superadmins'
  get 'dealers' => 'users#dealers' 

  resources :user_types, except: :show

  # Enquiries
  resources :enquiry_email_uploads
  
  resources :enquiry_types, except: :show
  get '/enquiries/search' => 'enquiries#search'
  resources :enquiries do
    patch 'assign', on: :member
    patch 'verify_customer_info', on: :member
    patch 'create_hire_quote', on: :member
    get  'send_enquiry_mail' => 'enquiries#send_enquiry_mail'
  end
  match "/enquiries/search" => 'enquiries#search', via: :post, as: 'search_enquiries'

  get 'enquire' => 'enquiries#new'
  get 'enquiry/submitted' => 'enquiries#enquiry_submitted'

  # Notification
  resources :notification_types

  match 'notifications/update_resources' => 'notifications#update_resources', via: :get
  match 'notifications/update_event_types' => 'notifications#update_event_types', via: :get
  match 'notifications/:id/record_action' => 'notifications#record_action', via: :get, as: :record_notification_action
  resources :notifications do
    post 'complete', on: :member
  end

  # Allocated Stock
  resources :stocks do
    get 'convert_to_vehicle', on: :member
  end

  # Stock Requests
  resources :stock_requests do
    get 'send_notifications'
    get 'complete'
    post 'create_stock'
  end

  # Vehicle Make and Models
  resources :vehicle_makes, except: :show
  resources :vehicle_models do
    patch 'add_hire_addon', on: :member
    patch 'remove_hire_addon', on: :member
    patch 'add_product_type', on: :member
    patch 'remove_product_type', on: :member
  end
  resources :search_tags, except: :show

  resources :fee_types, except: :show
  
  resources :hire_addons

  get '/hire_quotes/search' => 'hire_quotes#search'
  resources :hire_quotes do
    get 'view_customer_quote', on: :member
    get 'send_quote', on: :member
    get 'accept', on: :member
    get 'request_change', on: :member
    post 'create_amendment', on: :member
    
    resources :hire_quote_vehicles, except: :index do
      patch 'add_addon', on: :member
      patch 'remove_addon', on: :member
    end
  end  
  match "/hire_quotes/search" => 'hire_quotes#search', via: :post, as: 'search_hire_quotes'

  # Vehicles
  match 'vehicles/:vehicle_id/images/new/photo' => 'images#new_photo', as: 'vehicle_photo', via: :get
  match 'vehicles/:vehicle_id/images/new/document' => 'images#new_document', as: 'vehicle_document', via: :get

  # delete 'images' => 'images#destroy'

  resources :vehicles do
    resources :images, except: :new
    get 'workorders' => 'workorders#index'
    get 'notifications' => 'notifications#index'
    get 'workorders/new' => 'workorders#new'
    get 'workorders/:id' => 'workorders#show'
    get 'off_hire_jobs' => 'off_hire_jobs#index'
    get 'hire_agreements' => 'hire_agreements#index'
    get 'schedule' => 'vehicles#schedule'
    get 'notes' => 'vehicles#notes'

    get 'hire_agreement_data', defaults: { format: 'json' }, constraints: { format: 'json' }
    get 'workorder_data', defaults: { format: 'json' }, constraints: { format: 'json' }
    get 'build_order_data', defaults: { format: 'json' }, constraints: { format: 'json' }
    get 'off_hire_job_data', defaults: { format: 'json' }, constraints: { format: 'json' }
  end

  resources :vehicle_uploads

  get 'hire_vehicles' => 'vehicles#hire_vehicles'

  # Vehicle Log Entries
  resources :log_uploads
  resources :vehicle_logs do
    resources :log_uploads
    patch 'complete_from_workorder', on: :member
  end

  # Builds
  resources :build_uploads
  resources :builds do
    get 'build_orders' => 'builds#build_orders'
    resource :build_specification, except: [:index] do
      member do
        get :complete
      end
    end
  end

  # Build Orders
  resources :build_order_uploads
  resources :build_orders do
    get 'send_notifications' => 'build_orders#send_notifications'
    get 'complete_step1' => 'build_orders#complete_step1'
    get 'complete_step2' => 'build_orders#complete_step2'
    get 'submit_invoice' => 'sp_invoices#submit'
    patch 'complete_submit', on: :member
    patch 'submit_sp_invoice', on: :member
  end

  # Workorder Types
  resources :workorder_types, except: :show
  resources :workorder_type_uploads

  # Workorders
  resources :workorder_uploads
  resources :workorders do
    resources :workorder_uploads
    get 'send_notifications' => 'workorders#send_notifications'
    get 'complete_step1' => 'workorders#complete_step1'
    get 'complete_step2' => 'workorders#complete_step2'
    get 'submit_invoice' => 'sp_invoices#submit'
    patch 'submit_sp_invoice', on: :member
  end

  get 'workorders/complete'

  # PO Requests
  resources :po_request_uploads
  resources :po_requests do
    get 'send_notification'
  end

  # Hire Agreement Types
  resources :hire_agreement_types, except: :show
  resources :hire_agreement_type_uploads

  # Hire Agreements
  resources :hire_uploads
  resources :hire_agreements do
    resources :hire_uploads
    resources :on_hire_reports, except: [:index, :destroy]
    resources :off_hire_reports, except: [:index, :destroy] do
      resources :off_hire_jobs
      get 'off_hire_jobs' => 'off_hire_reports#off_hire_jobs'
    end
    get 'send_hire_agreement' => 'hire_agreements#send_hire_agreement'
  end

  match '/hire_agreements/:id/review' => 'hire_agreements#review', :via => :get, :as => :review_hire_agreement
  match '/hire_agreements/:id/accept' => 'hire_agreements#accept', :via => [:post]

  get 'hire_agreement/customers' => 'hire_agreements#customers'
  get 'hire_agreement/hire_vehicles' => 'hire_agreements#hire_vehicles'
  get 'hire_agreement/hire_vehicles_details' => 'hire_agreements#hire_vehicles_details'

  # On/Off Hire Reports |
  resources :on_hire_report_uploads
  resources :off_hire_report_uploads
  resources :on_hire_reports, except: [:index, :show]
  resources :off_hire_reports, except: [:index] do
    get 'off_hire_jobs' => 'off_hire_reports#off_hire_jobs'
  end

  # Off Hire Jobs
  resources :off_hire_job_uploads
  resources :off_hire_jobs do
    get 'send_notifications' => 'off_hire_jobs#send_notifications'
    get 'complete_step1' => 'off_hire_jobs#complete_step1'
    get 'complete_step2' => 'off_hire_jobs#complete_step2'
    get 'submit_invoice' => 'sp_invoices#submit'
    patch 'complete_submit', on: :member
    patch 'submit_sp_invoice', on: :member
  end

  # Master Quote Types
  resources :master_quote_types, except: :show

  # Master Quotes
  resources :master_quote_uploads

  resources :master_quotes do
    get 'duplicate' => 'master_quotes#duplicate'
    get 'title_page/new' => 'master_quote_title_pages#new'
    get 'title_page/:id/edit' => 'master_quote_title_pages#edit'
    get 'summary_page/new' => 'master_quote_summary_pages#new'
    get 'summary_page/:id/edit' => 'master_quote_summary_pages#edit'
    resources :master_quote_specification_sheets, as: 'specification_sheets' do
      get 'show' =>'master_quote_specification_sheets#show'
      end
  end
  
  get 'master_quotes_internationals/duplicate' => 'master_quotes_internationals#duplicate'
  resources :master_quotes_internationals do
    #get 'duplicate' => 'master_quotes_internationals#duplicate'
    get 'title_page/new' => 'master_quotes_internationals_title_pages#new'
    get 'title_page/:id/edit' => 'master_quotes_internationals_title_pages#edit'
    get 'summary_page/new' => 'master_quotes_internationals_summary_pages#new'
    get 'summary_page/:id/edit' => 'master_quotes_internationals_summary_pages#edit'
   
    resources :master_quote_specification_sheets, as: 'specification_sheets' do
      get 'show' =>'master_quote_specification_sheets#show'
      end
  end

  # Master Quote Title Pages
  resources :master_quote_title_pages, except: [:index, :show]

  # Master Quote Summary Pages
  resources :master_quote_summary_pages, except: [:index, :show]

  # Master Quote Items
  resources :master_quote_items, except: :show

  # Quotes
  resources :quote_uploads

  get '/quotes/search' => 'quotes#search'
  resources :quotes do
    get 'duplicate' => 'quotes#duplicate'
    get 'send_quote' => 'quotes#send_quote'
    get 'create_amendment' => 'quotes#create_amendment'
    get 'request_change' => 'quotes#request_change'
    get 'accept' => 'quotes#accept'
    get 'title_page/new' => 'quote_title_pages#new'
    get 'title_page/:id/edit' => 'quote_title_pages#edit'
    get 'cover_letter/new' => 'quote_cover_letters#new'
    get 'cover_letter/:id/edit' => 'quote_cover_letters#edit'
    get 'summary_page/new' => 'quote_summary_pages#new'
    get 'summary_page/:id/edit' => 'quote_summary_pages#edit'
    get 'create_from_master', :on => :collection
    get 'cancel' => 'quotes#cancel'
    patch 'update_po', on: :member
    get 'create_contract' => 'quotes#create_contract'
    resources :quote_specification_sheets, as: 'specification_sheets'
  end
  match "/quotes/search" => 'quotes#search', via: :post

  resources :vehicle_contracts, except: :destroy do
    patch 'verify_customer_info', on: :member
    patch 'upload_contract', on: :member
    get 'send_contract' => 'vehicle_contracts#send_contract'
  end
  match '/vehicle_contracts/:id/review' => 'vehicle_contracts#review', :via => :get, :as => :review_vehicle_contract
  match '/vehicle_contracts/:id/view_customer_contract' => 'vehicle_contracts#view_customer_contract', :via => :get, :as => :view_customer_contract
  match '/vehicle_contracts/:id/accept' => 'vehicle_contracts#accept', :via => [:post]
  match '/vehicle_contracts/:id/upload_contract' => 'vehicle_contracts#upload_contract', :via => [:post]

  match "/vehicle_contracts/:id/terms_conditions_download" => "vehicle_contracts#terms_conditions_download", :via => :get, :as => :download_terms_conditions

  # Sales Orders
  resources :sales_order_uploads
  resources :sales_orders do
    get 'send_notification'
  end

  # Quote Title Pages, Cover Letters and Summary Pages
  resources :quote_title_pages, except: [:index, :show]
  resources :quote_cover_letters, except: [:index, :show]
  resources :quote_summary_pages, except: [:index, :show]

  # Schedule Views
  get 'schedule_views/search' => 'schedule_views#search'
  post 'schedule_views/submit' => 'schedule_views#submit'
  get 'schedule_views/destroy_vehicle' => 'schedule_views#destroy_vehicle'
  resources :schedule_views do
    get 'vehicles' => 'schedule_views#vehicles', defaults: { format: 'json' }, constraints: { format: 'json' }
    get 'hire_agreement_data' => 'schedule_views#hire_agreement_data', defaults: { format: 'json' }, constraints: { format: 'json' }
    get 'workorder_data' => 'schedule_views#workorder_data', defaults: { format: 'json' }, constraints: { format: 'json' }
    get 'build_order_data' => 'schedule_views#build_order_data', defaults: { format: 'json' }, constraints: { format: 'json' }
    get 'off_hire_job_data' => 'schedule_views#off_hire_job_data', defaults: { format: 'json' }, constraints: { format: 'json' }
  end

  # Schedule Data
  get 'hire_agreements_data' => 'hire_agreements#schedule_data', defaults: { format: 'json' }, constraints: { format: 'json' }
  get 'workorders_data' => 'workorders#schedule_data', defaults: { format: 'json' }, constraints: { format: 'json' }
  get 'build_orders_data' => 'build_orders#schedule_data', defaults: { format: 'json' }, constraints: { format: 'json' }
  get 'off_hire_jobs_data' => 'off_hire_jobs#schedule_data', defaults: { format: 'json' }, constraints: { format: 'json' }
  get 'hire_vehicles_data' => 'vehicles#hire_vehicles_data', defaults: { format: 'json' }, constraints: { format: 'json' }

  get '/schedule', to: 'schedule#index'
  get 'schedule/vehicles'
  get 'schedule/hire_agreement_data'
  get 'schedule/workorder_data'
  get 'schedule/build_order_data'
  get 'schedule/off_hire_job_data'

  # Service Provider Invoices
  resources :sp_invoices, except: [:new] do
    get 'process_sp_invoice'
  end

  get 'accounts/sp_invoices', to: 'sp_invoices#index'

  # Taxes
  resources :taxes, except: :show

  # Invoice Companies
  resources :invoice_companies
  get 'config/companies', to: 'invoice_companies#index'

  # Notes
  match 'note/:id/send_notifications', to: "notes#send_notifications", via: "post", as: :send_notifications 
  resources :notes, only: [:create, :update, :destroy]

  # Document Types
  resources :document_types  

  # PhotoCategory Types
  resources :photo_categories 

  # Quote Item Types
  resources :quote_item_types

  # System Errors
  get 'system_errors/log', to: 'system_errors#log'
  get 'system_errors/unresolved_log', to: 'system_errors#unresolved_log'
  resources :system_errors, only: [:show, :edit, :update, :destroy]

  namespace :api do
    resources :enquiries, only: [:create, :show], defaults: { format: 'json' }, constraints: { format: 'json' }
    resources :newsletter_subscriptions, only: [:create, :show], defaults: { format: 'json' }, constraints: { format: 'json' }

    get 'enquiry_types' => 'enquiries#enquiry_types', defaults: { format: 'json' }, constraints: { format: 'json' }
  end
end
