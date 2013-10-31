
Simsearch::Application.routes.draw do

  match 'feedbacks' => 'feedbacks#create', :as => :feedback

  match 'feedbacks/new' => 'feedbacks#new', :as => :new_feedback

  root :to => 'frontdoor#root'
  
  get "home" => "frontdoor#home"
  
  get "signin" => "frontdoor#identity"
  get "signout" => "frontdoor#identity"
  get "register" => "frontdoor#identity"
  get "subscribe" => "frontdoor#identity"
  get "profile" => "frontdoor#profile"
  get "searches" => "searches#searches"

  get "privacy" => "frontdoor#privacy"
  get "terms" => "frontdoor#terms"
  get "about" => "frontdoor#about"

  post "signin" => "frontdoor#signin"
  post "register" => "frontdoor#register"
  post "signout" => "frontdoor#destroy_session"
  post "update_username" => "frontdoor#update_username"
  post "update_password" => "frontdoor#update_password"

  get "autocomplete_security_ticker" => "frontdoor#autocomplete_security_ticker" # to autocomplete

  post "search" => "frontdoor#search"  # to evaluate the submitted search content
  get "search" => "frontdoor#search_with_id" # to retrieve earlier search results.
  get "search_detail" => "frontdoor#search_detail"

  post "share" => "searches#share"
  post "addfavorite" => "searches#addfavorite"

  # API calls that return JSON only, no rendering of HTML templates.
  get "get_search_results" => "frontdoor#get_search_results"
  get "get_search_summary" => "frontdoor#get_search_summary"
  get "get_search_info" => "frontdoor#get_search_info"
  get "get_price_time_series" => "frontdoor#get_price_time_series"
  get "get_growth_time_series" => "frontdoor#get_growth_time_series"
  get "get_security_snapshot" => "frontdoor#get_security_snapshot"
  get "get_share_history" => "searches#get_share_history"
end
