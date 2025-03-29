Rails.application.routes.draw do
  get 'notifications/index'
  get 'dashboard/index'

  devise_for :users


  # namespace :admin do
  #   get 'users/new'
  #   get 'users/create'
  #   resources :users, only: [:new, :create]
  # end

  namespace :admin do
    resources :users, only: [:new, :create] # Allow only new and create actions
  end

  get '/admin/users', to: redirect('/admin/users/new')



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Routes for different dashboards
  get 'auditee_dashboard', to: 'dashboard#auditee', as: 'auditee_dashboard'
  get 'qa_manager_dashboard', to: 'dashboard#qa_manager', as: 'qa_manager_dashboard'
  get 'senior_manager_dashboard', to: 'dashboard#senior_manager', as: 'senior_manager_dashboard'
  get 'auditor_dashboard', to: 'dashboard#auditor', as: 'auditor_dashboard'




  #Takes you to the profile page after clicking the name
  get 'profile', to: 'users#show', as: :profile

  #Get to your notifications
  get 'notifications', to: 'notifications#index'

  # Defines the root path route ("/")

  # For logged in users
  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
  end

  # For non logged in users
  unauthenticated do
    root to: 'pages#home'
  end

  resources :audits do
    resources :audit_closure_letters, only: [:new, :create]
  end
  resources :create_edit_audits, only: [:new, :create, :edit, :update]

  # Defines the route for the audit request letter creation page ('/create-audit-request-letter')
  get 'letters/create-audit-request-letter', to: 'letters#audit_request_letter_create'

  # Defines the route for the audit request letter view page ('/view-audit-request-letter')
  get 'letters/view-audit-request-letter', to: 'letters#audit_request_letter_view'

  # Defines the route for the audit request letter review page ('/review-audit-request-letter')
  get 'letters/review-audit-request-letter', to: 'pages#audit_request_letter_review'
end
