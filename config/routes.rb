Rails.application.routes.draw do
  # ===一般ユーザ側のルーティング===
  # ユーザのルーティング
  resource :member, only: [ :edit, :show, :update ]
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
  resource :making, except: [ :show ]
  # ジャンルのルーティング
  resources :categories, only: [ :index, :show ]
  # 一般ユーザアカウント管理への設定
  devise_for :users

  # ===管理者側のルーティング===
  namespace :admin do
    # ユーザのルーティング
    resources :members, except: [ :new, :create, :destroy ]
    # ジャンルのルーティング
    resources :categories
  end
  #管理者アカウント管理への設定
  devise_for :admins

  # ===共通===
  # アバウトページのルーティング
  get '/about' => 'homes#about'
  # トップページのルーティング
  root to: 'homes#top'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
