Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'sessions#new'

  resources :users
  resources :messages
  resources :assignments
  
  get '/about/',	to: 'static_pages#about'
  get '/workinprogress/', to: 'static_pages#construction'

  get '/login',   to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get '/auth/google_oauth2/callback', to: 'sessions#oauth'

  get '/adduser',  to: 'users#new'
  get '/changepassword', to: 'users#change_password'

  get '/messages/page/:page_type/:page_token/',  to: 'messages#page'
  get '/messages/page/:page_type/',  to: 'messages#page'

end
