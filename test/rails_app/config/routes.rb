Rails.application.routes.draw do
  namespace :admin do
    resources :reports
  end

  resources :documents
  resources :images, only: :show
end
