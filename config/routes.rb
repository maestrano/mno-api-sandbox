MnoApiSandbox::Application.routes.draw do

  # Static routes
  root to: "pages#index"
  get '/app_access_unauthorized', to: "pages#app_access_unauthorized"
  get '/app_logout', to: "pages#app_logout"
  get '/sso', to: "pages#sso"
  get '/sso_trigger', to: "pages#sso_trigger"


  # Resources
  resources :apps
  resources :bills
  resources :recurring_bills
  resources :groups
  resources :group_user_rels
  resources :logs, only: [:index]
  resources :metadata

  resources :users do
    member do
      get 'regenerate_sso_session'
    end
  end

  # API Routes
  namespace :api do
    #reports endpoint
    namespace :reports do
      scope ':group_id' do
        scope ':resource' do
          match '', :controller => 'resources', :action => 'cors_preflight_check', :constraints => {:method => 'OPTIONS'}
          resources '', as: :resource, controller: "resources", only: [:index]
        end

      end
    end

    # OpenID Provider
    namespace :openid do
      resources :provider, only: [:show] do
        member do
          post :/, to: 'provider#show'
          get :decide
          get :proceed
          get :complete
        end

        resources :users, only: [:show]
      end
    end

    namespace :v1 do
      # Base - Ping action
      get 'ping', to: 'base#ping'

      # Auth API
      namespace :auth do
        resources :saml, only: [:index, :show]
      end

      # Billing API
      namespace :account do
        match '/bills', :controller => 'bills', :action => 'cors_preflight_check', :constraints => {:method => 'OPTIONS'}
        match '/recurring_bills', :controller => 'recurring_bills', :action => 'cors_preflight_check', :constraints => {:method => 'OPTIONS'}
        match '/groups', :controller => 'groups', :action => 'cors_preflight_check', :constraints => {:method => 'OPTIONS'}
        match '/users', :controller => 'users', :action => 'cors_preflight_check', :constraints => {:method => 'OPTIONS'}

        resources :bills, only: [:index, :show, :create, :destroy]
        resources :recurring_bills, only: [:index, :show, :create, :destroy]
        resources :groups, only: [:index, :show]
        resources :resellers, only: [:index, :show] do
          resources :groups, only: [:index], controller: :reseller_groups
        end

        resources :users, only: [:index, :show] do
          post :authenticate, on: :collection
        end
      end
    end
  end


  #================================================
  # Connec API > V2 > Entities
  #================================================
  # URLs like:
  # /connec/api/v2/:group_id/items
  # /connec/api/v2/:group_id/items/:id
  #
  namespace :connec do
    namespace :api do
      namespace :v2 do
        scope ':group_id' do

          scope ':resource' do
            match '', :controller => 'resources', :action => 'cors_preflight_check', :constraints => {:method => 'OPTIONS'}
            resources '', as: :resource, controller: "resources", only: [:index, :show, :create, :update]
            resource '', controller: "resources", only: [:update]
          end

        end
      end
    end
  end
end
