MnoApiSandbox::Application.routes.draw do
  
  # Static routes
  root to: "pages#index"
  get '/app_access_unauthorized', to: "pages#app_access_unauthorized"
  get '/sso', to: "pages#sso"
  get '/sso_trigger', to: "pages#sso_trigger"
  
  
  # Resources
  resources :apps
  resources :bills
  resources :groups
  resources :group_user_rels
  
  resources :users do
    member do
      get 'regenerate_sso_session'
    end
  end
  
  # API Routes
  namespace :api do
    namespace :v1 do
      # Base - Ping action
      get 'ping', to: 'base#ping'
      
      # Auth API
      namespace :auth do
        resources :saml, only: [:index, :show]
      end
      
      # Billing API
      namespace :billing do
        resources :bills, only: [:index, :show, :create, :destroy]
      end
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
