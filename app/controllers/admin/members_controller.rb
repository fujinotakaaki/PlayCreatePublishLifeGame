class Admin::MembersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @users = User.all
  end

  def edit
    # ユーザ情報の取得
    @user = User.find( params[ :id ] )
  end

  def show
    # ユーザ情報の取得
    @user = User.find( params[ :id ] )
  end

  def update
    # ユーザ情報の取得
    @user = User.find( params[ :id ] )
    if @user.update( user_params ) then
      flash[ :success ] = 'ユーザ情報の更新に成功しました。'
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require( :user ).permit( :email, :name, :introduction, :profile_image )
  end
end
