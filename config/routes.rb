Rails.application.routes.draw do
  scope "(:locale)" do
    # ===一般ユーザ側のルーティング============
    # ユーザ退会確認ページへのルーティング
    get 'mambers/:id/confirm' => 'members#confirm', as: 'confirm_member'
    # ユーザのルーティング
    resources :members, except: [ :index, :new, :create, :destroy ]
    # パターンのルーティング
    resources :patterns do
      # コメント投稿のルーティング
      resource :post_comment, only: [ :create, :show ]
      # お気に入りのルーティング
      resource :favorite, only: [ :create, :destroy ]
    end
    # 表示形式のルーティング
    resources :display_formats, except: [ :index ]
    # パターン作成のルーティング
    resource :making, except: [ :show ]
    # ジャンルのルーティング
    resources :categories, only: [ :index, :show ]
    # ユーザアカウント管理の設定(devise)
    scope module: :users do
      devise_for :users, controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations',
        passwords: 'users/passwords',
      }
    end
    # サインアップエラー時のリロードではroot_pathへ飛ばす（エラー回避のため）
    get 'users' => 'homes#top'
    # パスワード再発行用メールの要求エラー時のリロードではroot_pathへ飛ばす（エラー回避のため）
    get 'users/password' => 'homes#top'

    # ===管理者側のルーティング===============
    namespace :admin do
      # Homesのルーティング
      get 'top' => 'homes#top', as: 'root'
      # ユーザのルーティング
      resources :members, only: [ :index, :show ]
      # ジャンルのルーティング
      resources :categories, except: [ :new, :show ]

      resources :patterns, only: [ :index ]
    end
    # 管理者アカウント管理への設定
    devise_for :admins, skip: :all
    devise_scope :admin do
      get 'admin/sign_in' => 'admin/users/sessions#new', as: 'new_admin_session'
      post 'admin/sign_in' => 'admin/users/sessions#create', as: 'admin_session'
      delete 'admin/sign_out' => 'admin/users/sessions#destroy', as: 'destroy_admin_session'
    end

    # ===共通===
    # アバウトページのルーティング
    get '/about' => 'homes#about'
    # トップページのルーティング
    root to: 'homes#top'

    if Rails.env.development? then
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
