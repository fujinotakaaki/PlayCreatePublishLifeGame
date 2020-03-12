Rails.application.routes.draw do
  # ===一般ユーザ側のルーティング===
  # ユーザのルーティング
  resources :members, except: [:new, :create, :destroy]
  # パターンのルーティング
  resources :patterns, except: [ :new ] do
    # コメント投稿のルーティング
    resource :post_comment, only: [ :create, :destroy ]
    #お気に入りのルーティング
    resource :favorite, only: [ :create, :destroy ]
  end
  # 表示形式のルーティング
  resources :display_formats, except: [ :show ]
  # パターン作成のルーティング
  resource :making, only: [ :edit, :update, :destroy ]
  # ジャンルのルーティング
  resources :categories, only: [ :index, :show ]
  # ユーザアカウント管理の設定(devise)
  scope module: :users do
    devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',
      passwords: 'users/passwords'
    }
  end

  # ===管理者側のルーティング===
  namespace :admin do
    # Homesのルーティング
    get 'top' => 'admin/homes#top', as: 'root'
    # ユーザのルーティング
    resources :members, except: [ :new, :create, :destroy ]
    # ジャンルのルーティング
    resources :categories
  end
  #管理者アカウント管理への設定
  devise_for :admins, skip: :all
  devise_scope :admin do
    get      'admin/sign_in'   => 'admin/users/sessions#new', as: 'new_admin_session'
    post    'admin/sign_in'   => 'admin/users/sessions#create', as: 'admin_session'
    delete 'admin/sign_out' => 'admin/users/sessions#destroy', as: 'destroy_admin_session'
  end

  # ===共通===
  # アバウトページのルーティング
  get '/about' => 'homes#about'
  # トップページのルーティング
  root to: 'homes#top'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
