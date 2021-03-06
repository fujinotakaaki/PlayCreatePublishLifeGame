class MembersController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :baria_user, except: [ :show ]

  def show
    # ユーザ情報取得
    @user = User.find( params[ :id ] )
    # 一覧表示内容の選定
    @patterns = begin
      if params[:favorite] then
        # お気に入り一覧の場合
        @user.favorite_patterns.page( params[ :page ] ).includes( :category ).reverse_order
      else
        # 該当ユーザの投稿一覧の場合
        @user.patterns.page( params[ :page ] ).includes( :category ).reverse_order
      end
    end
    @title = params[:favorite] ? 'お気に入り' : 'ユーザ投稿'
  end

  def edit
  end

  def update
    # （ログイン中の）ユーザ情報取得
    @user = current_user
    # ユーザ更新処理
    @user.update( user_params )
  end

  def confirm
  end

  private

  def user_params
    params.require( :user ).permit( :name, :introduction, :profile_image )
  end

  def baria_user
    # ログインユーザと一致しているか判定
    unless params[ :id ].to_i  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to root_path
    end
  end
end
