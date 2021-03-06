Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/playlists/recent', to: 'playlists#recent'
      get '/users/persist', to: 'users#persist'
      get '/users/checkauth', to: 'users#isAuthorized?'
      resources :users, only: [:create, :new, :index, :show]
      resources :songs, only: [:index, :show]
      resources :playlists
      post '/login', to: 'users#login'
      post '/search', to: 'songs#search'
      post '/spotifyauth', to: 'users#spotifyauth'
      get '/recent', to: 'songs#recent'
      post '/saved', to: 'playlists#editsaved'
      get '/saved', to: 'playlists#showsaved'
      get '/recommendation', to: 'songs#recommendation'
    end
  end

end
