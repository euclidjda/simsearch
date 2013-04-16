
Simsearch::Application.routes.draw do

  root :to => 'frontdoor#root'
  
  get "home" => "frontdoor#home"
  
  get "signin" => "frontdoor#identity"
  get "signout" => "frontdoor#identity"
  get "register" => "frontdoor#identity"
  get "subscribe" => "frontdoor#identity"
  get "searches" => "searches#searches"

  get "privacy" => "frontdoor#privacy"
  get "terms" => "frontdoor#terms"
  get "about" => "frontdoor#about"

  post "signin" => "frontdoor#signin"
  post "register" => "frontdoor#register"
  post "signout" => "frontdoor#destroy_session"

  get "autocomplete_security_ticker" => "frontdoor#autocomplete_security_ticker" # to autocomplete

  post "search" => "frontdoor#search"  # to evaluate the submitted search content
  get "search" => "frontdoor#search_with_id" # to retrieve earlier search results.
  get "search_detail" => "frontdoor#search_detail"

  get "get_search_results" => "frontdoor#get_search_results"
  get "get_search_summary" => "frontdoor#get_search_summary"
  get "get_price_time_series" => "frontdoor#get_price_time_series"
  get "get_growth_time_series" => "frontdoor#get_growth_time_series"

  # get "get_prices" => "api#get_prices"
  # get "get_performance" => "api#get_performance"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
