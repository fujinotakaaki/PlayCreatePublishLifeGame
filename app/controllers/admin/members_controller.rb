class Admin::MembersController < ApplicationController
  before_action :baria_user, only: [ :edit, :update ]
  before_action :set_user, only: [ :edit, :show, :update ]

  def index
    @users = User.all
  end

  def edit
  end

  def show
  end

  def update
    if @user.update( user_params ) then
      flash[ :success ] = 'ユーザ情報の更新に成功しました。'
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.permit( :user ).permit( :email, :name, :introduction, :profile_image_id, :is_deleated )
  end

  def baria_user
    # ログイン中のユーザでないならば
    unless current_user.id == params[ :id ] then
      # トップページへ強制送還
      redirect_to root_path
    end
  end

  def set_user
    # ユーザ情報の取得
    @user = User.find( params[ :id ] )
  end
end
