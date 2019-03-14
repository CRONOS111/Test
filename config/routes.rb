Rails.application.routes.draw do
  get '/hide', to: 'hide#start'
  get '/hide/i', to: 'hide#new'
  post '/hide/i', to: 'hide#new'
  get '/hide/i/destroy', to: 'hide#destroy'
  get '/hide/i/encode', to: 'hide#encode'
  
  get '/seek', to: 'seek#start'
  get '/seek/i', to: 'seek#new'
  post '/seek/i', to: 'seek#new'
  get '/seek/i/decode', to: 'seek#decode'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
