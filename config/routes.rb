Rails.application.routes.draw do
  post 'sessions/sign_up'
  post 'sessions/sign_in'
  get 'sessions/me'
  delete 'sessions/sign_out'
  devise_for :users
end
