class DisplayFormatsController < ApplicationController
  before_action :authenticate_user!
  before_action :baria_user, only: [ :edit, :update, :destroy ]
  # set_to_gonメソッドのインクルード
  include PatternsHelper

  def new
    @display_format = DisplayFormat.new
    # ログインユーザの投稿したセルの表示形式を全件取得
    @display_formats = current_user.display_formats
    set_to_gon( Pattern.take )
  end

  def create
    # 新規データ取得
    @display_format = current_user.display_formats.build( display_format_params )
    # 新規データ保存
    @display_format.save
  end

  def show
    # 詳細データの取得（Patterns#new, #editで使用）
    display_format = DisplayFormat.find( params[ :id ] )
    # jsonデータ送信用に形式変換
    display_format_as_json = {
      # cssの設定
      cssOptions:   display_format.as_json_css_options,
      # セルの表示定義設定
      cellConditions: display_format.as_json_cell_conditions
    }
    # jsonデータを返す
    render json: display_format_as_json
  end

  def edit
    # 編集データ取得
    @display_format = DisplayFormat.find( params[ :id ] )
    # 編集データが使われている表示形式を取得（なければ適当なパターンを使用）
    set_to_gon( @display_format.patterns.take || Pattern.take )
  end

  def update
    # 編集データ取得
    @display_format = DisplayFormat.find( params[ :id ] )
    # 編集データ更新
    @display_format.update( display_format_params )
  end

  def destroy
    # 削除したいデータ取得
    display_format = DisplayFormat.find( params[ :id ] )
    display_format.destroy
    # 一覧ページへ
    redirect_to member_path( current_user )
  end

  private
  def display_format_params
    params.require( :display_format ).permit( :name, :alive, :dead,
      :font_color, :background_color, :line_height_rate, :letter_spacing, :font_size )
  end

  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless DisplayFormat.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => rootへ
      redirect_to root_path
    end
  end
end
