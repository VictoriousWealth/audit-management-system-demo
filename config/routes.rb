Rails.application.routes.draw do
  get 'qa_manager_dashboard', to: 'qa_dashboard#qa_manager', as: 'qa_dashboard' 
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :create_edit_audits, only: [:new, :create, :edit, :update]

  # Defines the root path route ("/")
  root "pages#home"
  
  resources :audits do
    resources :audit_closure_letters, only: [:new, :create]
  end

  # Defines the route for the audit request letter creation page ('/create-audit-request-letter')
  get 'letters/create-audit-request-letter', to: 'letters#audit_request_letter_create'

  # Defines the route for the audit request letter view page ('/view-audit-request-letter')
  get 'letters/view-audit-request-letter', to: 'letters#audit_request_letter_view'
  
  # Defines the route for the audit request letter review page ('/review-audit-request-letter')
  get 'letters/review-audit-request-letter', to: 'pages#audit_request_letter_review'
end
