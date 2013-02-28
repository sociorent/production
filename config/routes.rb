Sociorent::Application.routes.draw do



  get "item_history/index"

  mount RailsAdmin::Engine => '/cb_admin', :as => 'rails_admin'

  ActiveAdmin.routes(self)
  
  get 'aboutus' => 'static_pages#about_us'
  get 'pricing' => 'static_pages#pricing'
  get 'college_ambassadors' => 'static_pages#colleges'
  get 'contactus' => 'static_pages#contactus'
  get 'privacy_policy' => 'static_pages#privacypolicy'
  get 'terms_of_use' => 'static_pages#termsofuse'

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

  namespace :ab_admin do
    post 'orders/new/fetch_amounts' => 'orders#fetch_amount'
    post 'orders/:id/edit' => 'orders#update'
    post 'orders/create' => 'orders#create'
  end

  devise_for :counters

  ##P2P Routes
  namespace :p2p do


    resources :messages
    resources :items
    resources :images
    resources :credits 

    scope 'admin' do
      #scaffold controller and view
      resources :categories ,:products ,:specs ,:service_pincodes

        root :to => 'categories#index'
    end

      get "categories/set_category" => "categories#set_category"
      get "categories/sub_category" => "categories#sub_category"

      match 'getcategories' => "categories#getcategories"

      match 'getcities' => "cities#list"

      post 'users/list' => 'users#list'
      post 'users/verifymobile/code' => 'users#getcode'
      post 'users/verifymobile/:code' => 'users#verifycode'


      post 'location' => 'users#setlocation'
      post 'guesslocation' => 'users#guesslocation'

      post 'items/:id' => 'items#update'

      match 'getbook_details/:isbn13' => "items#getbook_details"

      get 'getserviceavailability/:itemid/:pincode' => 'service_pincodes#check_availability'
      get '' => "index#index"
      get 'sellitem' => "items#new"
      get 'getbrand/:id' => "items#get_brands"
      get 'getattributes/:id' => "items#get_attributes"
      get 'getspec/:id' =>  "items#get_spec"
      get 'getsubcategories' => "items#get_sub_categories"
      get 'welcome' => 'users#welcome'
      post 'welcome' => 'users#user_first_time'

      match 'itempayment/:id' => 'items#sellitem_pricing'
      get 'delete/:id' => "items#destroy"
      
      post 'addimage/:item_id' => "items#add_image"
      get  'addimage/:form_id/form' => "items#sellitem_pricing"

      get 'sold/:id' => "items#sold"

      get 'mystore(/:query(/user/:id))' => 'items#inventory'

      get 'dashboard' => 'users#dashboard'
      match 'approve(/:query)' => 'items#approve'
      match 'approve/user/:id' => 'items#approve'
      match 'disapprove' => 'items#disapprove'
      match 'disapprove/user/:id' => 'items#disapprove'
      match 'waiting(/user/:id)' => 'items#waiting'
      
      get 'getmessages(/:id)' => 'messages#getmessages'

      match 'search/q/:query' => "index#search_query"

      match 'search/c/:cat(/:prod)' => "index#search_cat"

      match "search/:id" =>"index#search"

      

      match ":cat/filters(/*applied_filters)" =>"index#browse_filter" ,  :applied_filters => /[^\/]*/ 
      match ":cat/:prod/filters(/*applied_filters)" =>"index#browse_filter"  ,:applied_filters => /[^\/]*/ 

      get ':cat/:prod/:item' => 'items#view' ,:as => :item_url
      get ':cat(/:prod)' => "index#browse" 

  end


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
