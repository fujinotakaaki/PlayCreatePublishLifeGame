class MembersController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :baria_user,                 only: [ :update, :destroy ]

  def show
    # ユーザ情報取得
    @user = User.find( params[ :id ] )
    @patterns = @user.patterns.page( params[ :page ] ).includes(:user, :category, :favorites, :post_comments).reverse_order
  end

  def edit
  end

  def update
    # （ログイン中の）ユーザ情報取得
    @user = User.find( params[ :id ] )
    # ユーザ更新処理
    @user.update!( user_params )
  end

  private
  def user_params
    params.require( :user ).permit( :id, :name, :introduction, :profile_image )
  end


  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless params[ :id ]  == user_params[ :id ] then
      # 不一致 => 一覧ページへ
      redirect_to root_path
      # redirect_to current_user
    end
  end
end
