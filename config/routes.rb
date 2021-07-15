Rails.application.routes.draw do
  resources :invoices
  resources :bills
  get 'bill/pay', to: "bills#pay"
  post 'bill/pay', to: "bills#pay"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
