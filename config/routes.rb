Kickstarter::Application.routes.draw do
  resources :subscriptions, only: [:new, :create]
  mount Ckeditor::Engine => '/ckeditor'
  root :to => 'projects#index'
  controller :sessions do
    get "login" => :new
    post "login" => :create
    get "logout" => :destroy
  end
  match 'auth/:provider/callback', to: 'sessions#facebook_create', provider: 'facebook', via: [:get, :post], as: :facebook_callback
  match 'auth/failure', to: redirect('/'), via: [:get, :post]

  match "/contacts/gmail/get_contacts", controller: "contacts", action: "gmail_callback", via: [:get, :post]
  match "/contacts/failure", controller: "contacts", action: "failure", via: [:get, :post]
  post "send_email", controller: "contacts"
  namespace :payment do
    namespace :stripe do
      get "charges/new_card"
      post "charges", controller: 'charges', action: 'create_card'
    end
    namespace :paypal do
      match "notify", controller: 'notifications', action: 'create', via: [:get, :post]
    end
  end

  match 'search', controller: 'searches', action: 'search', via: :get, as: :search_results

  resources :projects do
    get "/contacts_import_instructions", controller: "contacts", action: "import_instructions", on: :member
    get "/get_gmail_contacts", controller: "contacts", action: "get_gmail_contacts", on: :member
    match 'category/:category', action: 'category', via: [:get, :post], on: :collection
    match 'location/:location', action: 'location', via: [:get, :post], on: :collection
    get 'rewards/choose', on: :member, controller: 'rewards', action: 'choose'
    get 'this_week', on: :collection
    get 'new_message', on: :member, as: :new_message
    get 'back', on: :member
    get 'pledge', controller: 'pledges', action: 'new', on: :member
    post 'create_pledge', controller: 'pledges', action: 'create', on: :member
    get 'new_reward', on: :collection
    get 'new_image', on: :collection
    get 'story', controller: 'stories', action: 'new', on: :member
    get 'info', on: :member
    get 'rewards', controller: 'rewards', action: 'new', on: :member
    patch 'create_story', controller: 'stories', action: 'create', on: :member
    patch 'create_info', on: :member
    patch 'create_rewards', controller: 'rewards', action: 'create', on: :member
    get 'admin_conversation', controller: 'admin/messages', action: 'index', on: :member
    post 'create_admin_conversation', controller: 'admin/messages', action: 'create', on: :member
    get 'description', on: :member
    get 'backers', on: :member
  end
  get "my_projects", to: 'projects#user_owned'

  get '/admin', controller: 'sessions', action: 'new', as: :admin_root
  namespace :admin do
    get "users", action: 'index', controller: :users
    delete "users", action: 'destroy', controller: :users
    post "users/:id/make_admin", action: 'make_admin', controller: :users, as: :make_admin
    resources :projects, only: [:index] do
      get "approve", on: :member
      get "reject", on: :member
    end
  end

  resources :messages, only: [:index, :show] do
    post "create", on: :member, as: :create
  end

  resources :users, only: [:create, :show, :update] do
    get "signup", to: 'users#new', on: :collection
    get "/edit_profile", to: 'users#edit', as: :edit, on: :member
  end
  # post "users", to: 'users#create'
  # get "signup", to: 'users#new'
  # get "users/:id/edit_profile", to: 'users#edit', as: :edit_user_profile
  # get "users/:id", to: 'users#show', as: :user
  # patch "users/:id", to: 'users#update'
  # put "users/:id", to: 'users#update'
  # delete "users/:id", to: 'users#destroy'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
