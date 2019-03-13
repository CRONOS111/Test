Rails.application.routes.draw do
  get '/hide', to: 'hide#start'
  get '/hide/i', to: 'hide#new'
  post '/hide/i', to: 'hide#new'
  get '/hide/i/destroy', to: 'hide#destroy'
  get '/hide/i/encode', to: 'hide#encode'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
