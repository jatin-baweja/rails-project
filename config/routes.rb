Kickstarter::Application.routes.draw do
  root :to => 'projects#index'
  controller :sessions do
    get "login" => :new
    post "login" => :create
    get "logout" => :destroy
  end
  resources :rewards
  resources :stories

  resources :projects do
    get 'back', on: :member
    get 'new_reward', on: :collection
  end
  get "my_projects", to: 'projects#user_owned'

  namespace :admin do
    root "projects#pending_for_approval"
    get "projects/pending_for_approval"
    resources :projects, except: :all do
      get "approve", on: :member
    end
    controller :sessions do
      get "login" => :new
      post "login" => :create
      get "logout" => :destroy
    end
  end

  post "users", to: 'users#create'
  get "signup", to: 'users#new'
  get "users/:id/edit_profile", to: 'users#edit', as: :edit_user_profile
  get "users/:id", to: 'users#show', as: :user
  patch "users/:id", to: 'users#update'
  put "users/:id", to: 'users#update'
  delete "users/:id", to: 'users#destroy'

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
