class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]

  def index
    # config/initializers/kaminari_config.rb
    @patterns = Pattern.page( params[ :page ] ).reverse_order
  end

  def edit
    # before_action :baria_userでデータ取得済みのため下記処理は実施しない
    # @pattern = Pattern.find( params[ :id ] )
  end

  def show
    @pattern = Pattern.find( params[ :id ] )
    @latest_comment = PostComment.order(created_at: :desc).find_by( pattern_id: params[ :id ] )
    gon.push(
      # pattern: @pattern,
      # pattern_rows: @pattern.pattern_rows,
      display_format: @pattern.display_format
    )
  end

  def update
    # before_action :baria_userでデータ取得済みのため下記処理は実施しない
    # @pattern = Pattern.find( params[ :id ] )
  end

  def destroy
    # before_action :baria_userでデータ取得済みのため下記処理は実施しない
    # @pattern = Pattern.find( params[ :id ] )
  end

  private
  def baria_user
    @pattern = Pattern.find( params[ :id ] )
    # ログインユーザと製作者が一致しているか判定
    unless @pattern.user_id  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to current_user
    end
  end
end
