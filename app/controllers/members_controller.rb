class MembersController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,              except: [ :index, :show ]

  def index
    # 全ユーザ情報取得
    @users = User.all
  end

  def show
    # ユーザ情報取得
    @user = User.find( params[ :id ] )
  end

  def edit
    # なし
  end

  def update
    # （ログイン中の）ユーザ情報取得
    @user = current_user
    # ユーザ更新処理
    if @user.update( user_params ) then
      # 成功 => マイページへ
      redirect_to @user
    else
      # 失敗 => 編集ページへもどる
      render :edit
    end
  end

  private
  def user_params
    params.require( :user ).permit( :email, :name, :introduction, :profile_image )
  end

  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless params[ :id ]  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to current_user
    end
  end
end
