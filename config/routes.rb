Rails.application.routes.draw do

  use_doorkeeper
  devise_for :users, :controllers => { :registrations => "registrations", :sessions => "sessions", :passwords => "passwords"}

  namespace :admin, as: :admin do
    resources :users, :only => [:index]
    resources :accounts, :only => [] do
      collection do
        get 'status'
      end
    end
    resources :transactions, :only => [:index] do
      collection do
        get 'csv'
      end
    end
  end

  scope module: :app do
    resources :banks, :only => [:index] do
      collection do
        get 'login_requirement'
        post  'login'
        post  'login_mfa'
      end
    end

    resources :accounts, :only => [:index, :create] do
      collection do
        post 'refresh'
        post 'refresh_all'
        post 'delete'
      end
    end

    resources :transactions, :only => [:index] do
      collection do
        get 'dashboard'
        get 'balance'
        get 'query'
      end
    end

  end

  scope module: :pages do
    get 'about'
    get 'services'
    get 'contact'
    post 'contact',                         action: :post_contact
    get 'faq'
    get 'terms-and-conditions',             action: :terms_and_conditions, as: :terms_and_conditions
    get 'privacy-policy',                   action: :privacy_policy, as: :privacy_policy
  end

  get 'users/me', to: 'users#me'

  get '*path', to: 'application#index'

  get '/', :controller=> 'application',:action=>'index'

  root :to => 'application#index'


end
