Rails.application.routes.draw do
  #Rota para página inicial
  root to: "pages#home"

  #Rota para cadastro de usuários
  resources :users, only: [ :new, :create ] 

  #Rota para sessões de usuário (login/logout)
  resource :session, only: [ :new, :create, :destroy ] 

  resources :passwords, param: :token
  resources :lists do
    resources :tasks
  end

  get "confirm/:token", to: "confirmations#edit", as: :edit_confirmation


end
