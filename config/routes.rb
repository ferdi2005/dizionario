Rails.application.routes.draw do
  root 'process#home'
  post 'process', to: 'process#process'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
