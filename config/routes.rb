Sociorent::Application.routes.draw do

  ActiveAdmin.routes(self)
  

  get "home/index"
  match "/search" => "home#search"
  post "home/book_request"
  post "home/add_to_cart"
  post "home/remove_from_cart"
  post "/orders/create"
  match "/welcome" => "users#get_user_details"
  match "/get_bank_details/:id" => "home#get_bank_details"
  post "/users/save_user_details"
  post "/orders/rented_show_more"
  post "/orders/rented_college"
  post "users/update"
  post "users/add_to_wishlist"
  post "users/wishlist"
  post "users/remove_from_wishlist"
  post "home/get_adoption_rate"
  post "home/make_review"
  post "users/select_reference"
  post "orders/counter_cash_payment"
  post "home/apply_intership"
  match "update_shipping" => "home#update_shipping"
  post "home/load_more"
  match "book/details/:id" => "home#book"
  match "validate/:type" => "home#validate"
  match "print_invoice/:order"=>"orders#print_invoice"
  match "getSignature" =>"home#citrus_signature"
  match "/verify_code" => "orders#verify_code"
  match "/print_label" => "home#print_label"
  match "/print_invoice" => "home#print_invoice"
  match "/get_colleges" =>"users#get_colleges"
  match "/get_streams" => "users#get_streams"

  #matches #book/isbn
  get '/book/:isbn' => "home#book_deatils"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end

  devise_for :counters

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  match '/system/*a', :to => 'errors#ignore_routing'

  match '*a', :to => 'errors#routing'
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
