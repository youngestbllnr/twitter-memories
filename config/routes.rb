Rails.application.routes.draw do
  ## Root
  root 'main#index'

  ## Dashboard
  get 'dashboard' => 'main#dashboard', as: 'dashboard'

  ## Dashboard actions
  get 'share' => 'main#share', as: 'share'
  get 'enable' => 'main#enable', as: 'enable'
  get 'disable' => 'main#disable', as: 'disable'

  ## Twitter Omniauth
  match '/auth/:provider/callback', to: 'sessions#create', via: 'get'
  match '/auth/failure', to: redirect('/?auth=session_expired'), via: 'get'
  match '/auth/signout', to: 'sessions#destroy', via: 'get'
end