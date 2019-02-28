Rails.application.routes.draw do
  namespace :v1 do
    resource :auth, only: %i[create]
    post '/register' => 'auths#register'
    resources :sightings
    resources :subjects
    resources :subtypes
    resources :users, except: :create
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/sighting' => 'v1/sightings#create'
  get '/sighting/search' => 'v1/sightings#index'
  get '/sighting/:id' => 'v1/sightings#show'
end
