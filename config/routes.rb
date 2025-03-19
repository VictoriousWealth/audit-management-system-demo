Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"

  # -------- Routes for the audit request letter pages --------

  # Defines the route for the audit request letter creation page ('/create-audit-request-letter')
  get 'create-audit-request-letter', to: 'pages#audit_request_letter_create'
  # Defines the route for the audit request letter view page ('/view-audit-request-letter')
  get 'view-audit-request-letter', to: 'pages#audit_request_letter_view'
  # Defines the route for the audit request letter review page ('/review-audit-request-letter')
  get 'review-audit-request-letter', to: 'pages#audit_request_letter_review'


end
