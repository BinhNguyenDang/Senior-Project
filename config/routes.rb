Rails.application.routes.draw do
  get 'video_chat/index'
  get 'admin/dashboard'
  # Define resources for rooms and nested resources for messages
  resources :rooms do 
    resources :messages
    # Custom collection route for searching rooms
    collection do
      post :search
    end
  end

  get 'rooms/:id/video_chat', to: 'video_chat#index', as: 'video_chat'

  # leave_room_path(room)
  get 'rooms/leave/:id', to: 'rooms#leave', as: 'leave_room'
  # join_room_path(room)
  get 'rooms/join/:id', to: 'rooms#join', as: 'join_room'
  
  # Define the root path route to point to the 'home' action of the 'pages' controller
  root 'pages#home'
  
  # Configure Devise routes and controllers for user authentication
  # The controllers option allows you to customize which controllers Devise should use for specific authentication actions.
  # For Example, the sessions controller, authentication-related actions like signing in and signing out are handled. Here, it's specified that the users/sessions controller should be used.
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: "users/registrations"
  }

  
  # Define a route for users to access the sign-in page
  # devise_scope :user do
  #   get 'users', to: 'devise/sessions#new'
  # end
  
  # Define a route for accessing user profiles
  get 'user/:id', to: 'users#show', as: 'user'
  get 'users/search', to: 'users#search'
  get 'users/profile/:id', to: 'users#profile', as: 'profile'
  
  # Route to reveal the health status of the application
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Defines the root path route ("/")
  # root "posts#index"
end
