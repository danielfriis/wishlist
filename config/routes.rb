Wishlist::Application.routes.draw do

  resources :likes


  resources :admissions

  resources :activities

  match '/header_index', to: 'activities#header_index'

  use_link_thumbnailer

  namespace :plugin do
    match '/', to: 'lists#index'
    resources :lists
    resources :sessions
    resources :users

    match '/script', to: 'script#get'
    match '/widget', to: 'widget#index'
    match '/signin', to: 'sessions#new'
    match '/signout', to: 'sessions#destroy'
    match '/signup', to: 'users#new'
  end

  match '/bookmarklet', to: 'items#bookmarklet'

  namespace :admin do
    resources :users, :items, :wishes, :comments
    match '/lptester', to: 'items#lptester'
  end

  resources :items, only: [:show, :new, :create, :update, :destroy, :inspiration] do
    resources :comments, :defaults => { :commentable => 'item' }
  end
  resources :wishes do
    collection { post :sort }
    resources :comments, :defaults => { :commentable => 'wish' }
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :relationships, only: [:create, :destroy]
  resources :reservations
  resources :vendors, only: [:index, :new, :create]
  resources :vendors, path: "v" , except: [:index, :new, :create]
  resources :password_resets

  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match 'auth/:provider/callback', to: 'sessions#create_with_oauth'
  match 'auth/failure', to: redirect('/')

  root to: 'static_pages#home'
  get "sitemap.xml", to: "static_pages#sitemap", defaults: { format: "xml" }

  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/privacy', to: 'static_pages#privacy'
  match '/terms',   to: 'static_pages#terms'
  match '/linkpreview', to: 'items#linkpreview'
  match '/inspiration', to: 'items#inspiration'
  match '/search',  to: 'static_pages#search'
  match 'contact_support', to: 'mailing#contact_support'

  match '/item_suggestion', to:'items#item_suggestion'
  match '/user_suggestion', to:'users#invite_suggestion'
  match '/vendor_suggestion', to:'vendors#invite_suggestion'

  match 'v/:id/edit_admins', to: 'vendors#edit_admins', as: 'edit_admins'

  match '/:id/update_password', to: 'users#update_password', as: 'update_password'
  match '/:id/update_notifications', to: 'users#update_notifications', as: 'update_notifications'

  resources :users, only: [:index, :new, :create]
  resources :users, path: "" , except: [:index, :new, :create] do
    resources :comments, :defaults => { :commentable => 'user' }
    resources :lists do
      post :share
    end
    member do
      get :following, :defaults => { :followed => 'user' }
      get :followers, :defaults => { :followed => 'user' }
    end
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
