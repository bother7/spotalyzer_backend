Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create, :new, :index]
      resources :songs, only: [:index, :show]
      resources :playlists
      post '/login', to: 'users#login'
      get '/search/:term', to: 'songs#search'
      get '/callback', to: 'users#spotify'
    end
  end

end
