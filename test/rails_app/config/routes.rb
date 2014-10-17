Rails.application.routes.draw do
  namespace :admin do
    resources :reports
  end

  resources :documents
end
