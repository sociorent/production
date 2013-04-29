Sociorent::Application.routes.draw do



  get "item_history/index"

  mount RailsAdmin::Engine => '/cb_admin', :as => 'rails_admin'

  ActiveAdmin.routes(self)

  resources :static_pages

  get 'privacy_policy' => 'static_pages#privacypolicy'

  get 'page/:id' => 'static_pages#show'
  get 'college_ambassadors' => 'static_pages#colleges'

  # get 'aboutus' => 'static_pages#about_us'
  # get 'pricing' => 'static_pages#pricing'
  # get 'contactus' => 'static_pages#contactus'
  # get 'privacy_policy' => 'static_pages#privacypolicy'
  # get 'terms_of_use' => 'static_pages#termsofuse'

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
  namespace :street do


    root :to => "index#index"



    match 'aboutus' => 'static_pages#aboutus'
    match 'contactus' => 'static_pages#contactus'
    match 'privacy_policy' => 'static_pages#privacypolicy'
    match 'how_to_sell' => 'static_pages#howtosell'
    match 'how_to_buy' => 'static_pages#howtobuy'
    match 'buyer_protection' => 'static_pages#buyerprotection'
    match 'terms_of_use' => 'static_pages#terms'
    match 'seller_policy' => 'static_pages#sellerpolicy'
    match 'buyer_policy' => 'static_pages#buyerpolicy'

    post '/profile/updateaddress' => 'users#updateaddress'

    resources :messages
    match 'mark_as_read' =>'messages#mark_as_read'
    resources :items
    resources :images
    resources :credits

    match 'profile' => 'users#profile'

    #for adimn
    scope 'admin' do
      #scaffold controller and view
      resources :categories ,:products ,:specs ,:service_pincodes , :item_deliveries , :cities ,:static_pages


      match 'staticpage' => "users#staticpages"
      match 'static_pages/get_page/:page_name' => 'static_pages#get_page'

      match 'cities/:id/destory' => 'cities#destroy'

      root :to => 'categories#index'
      match 'jobs(/:job(/:cmd))' => 'users#show_jobs'
    end

    scope 'mob' do
      match 'getcities' => 'mobile#get_city'
      match  'recentitems(/:cat(/:prod))' => 'mobile#recent_items'
      get '/query/:query/:city' => 'mobile#recent_items'
      match 'update_view_count/:id'=> "mobile#update_view_count"
    end

      match "/get_city/:q" => "index#get_city"
      match "sellers/:id/:name" => "index#seller_items"

      match 'gettemplate' => 'items#downloadtemplate'

#      get "categories/set_category" => "categories#set_category"
#      get "categories/sub_category" => "categories#sub_category"

      match 'getcategories' => "categories#getcategories"
      match 'getsubcategories/:id' => "categories#getsubcategories"

      get   'getbrand/:id' => "categories#get_brands"

      match 'getcities' => "cities#list"

      post 'users/list' => 'users#list'
      post 'users/verifymobile/code' => 'users#getcode'
      post 'users/verifymobile/:code' => 'users#verifycode'
      get  'paymentdetails(/:bought)' => 'users#paymentdetails'
      get  'paymentdetails/:type/:id(/:bought)' => 'item_deliveries#print_invoice_label'


      post 'location' => 'users#setlocation'
      post 'guesslocation' => 'users#guesslocation'

      get 'sellitem' => "items#new"
      post 'items/:id' => 'items#update'

      match 'getbook_details/:isbn13' => "items#getbook_details"
      get 'getserviceavailability/:itemid/:pincode' => 'service_pincodes#check_availability'


      get 'faileduploads' => 'users#failed_uploads'

      get 'getattributes/:id' => "categories#get_attributes"
      get 'getspec/:id' =>  "items#get_spec"
      get 'welcome' => 'users#welcome'
      post 'welcome' => 'users#user_first_time'

      match 'itempayment/:id' => 'items#sellitem_pricing'
      get 'delete/:id' => "items#destroy"

      post 'addimage/:item_id' => "items#add_image"
      get  'addimage/:form_id/form' => "items#sellitem_pricing"

      get 'sold/:id' => "items#sold"


      get 'mystore(/:query(/user/:id))' => 'items#inventory'

      get 'dashboard' => 'users#dashboard'
      match 'upload_csv/'=>'items#upload_csv'
      match 'approve(/:query)' => 'items#approve'
      match 'approve/user/:id' => 'items#approve'
      match 'disapprove' => 'items#disapprove'
      match 'disapprove/user/:id' => 'items#disapprove'
      match 'waiting(/user/:id)' => 'items#waiting'
      get  'favourites' => 'users#favouriteusers'
      post 'favourites' => 'users#setfavourite'
      post 'favourites/:id' => 'users#setfavourite'
      match 'vendors(/:cmd)' => 'users#vendorsdetails'
      match 'getusers(/:query)' => 'users#getusers'

      get 'getfailed/:type/:dte' => 'users#download_failed'
      #post 'payments' => 'users#userpayments'

      get 'getmessages(/:id)' => 'messages#getmessages'

      match 'search/q' => "index#search_query"

      match 'search/c/:ignore1/:cat(/:ignore2/:prod)' => "index#search_cat"

      match "search/:id" =>"index#search"
      #citruspay response catching
      match "getCitursSignature" => "items#get_citrus_signature"
      match "update_citrus" => "items#update_online_payment"
      match ":ignore1/:cat/filters(/*applied_filters)" =>"index#browse_filter" ,  :applied_filters => /[^\/]*/
      match ":ignore1/:cat/:ignore2/:prod/filters(/*applied_filters)" =>"index#browse_filter"  ,:applied_filters => /[^\/]*/

      # get ':cat/:prod/:item' => 'items#view' ,:as => :item_url
      get ':ignore1/:cat/:ignore2/:prod/:item/:id' => 'items#view' ,:as => :item_url
      get ':ignore1/:cat(/:ignore2/:prod)' => "index#browse"
      match "update_shipping_address" => "users#update_shipping"
  end


  root :to => 'home#index'

  match '/system/*a', :to => 'errors#ignore_routing'
  match '/assets/*a', :to => 'errors#ignore_routing'

  match '*a', :to => 'errors#routing'

end
