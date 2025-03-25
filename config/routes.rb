Rails.application.routes.draw do
  get 'qa_manager_dashboard', to: 'dashboard#qa_manager', as: 'qa_dashboard' 
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"
end
