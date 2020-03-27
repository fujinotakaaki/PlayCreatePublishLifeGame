class DisplayFormatsController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]

  def new
    @display_format = DisplayFormat.new
  end

  def create
    # 新規データ取得
    @display_format = current_user.display_formats.build( display_format_params )
    # 新規データ保存
    if @display_format.save then
      # 成功 => 一覧ページへ
      redirect_to display_formats_path
    else
      # 失敗 => 作成ページへ
      puts '/ここみる'
      puts @display_format.inspect
      puts @display_format.errors.full_messages.inspect
      render :new
    end
  end

  def show
    # 詳細データの取得
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
  end

  def update
    # 編集データ取得
    @display_format = DisplayFormat.find( params[ :id ] )
    # 編集データ更新
    if @display_format.update( display_format_params ) then
      # 成功 => 一覧ページへ
      redirect_to display_formats_path
    else
      # 失敗 => 編集ページへ
      render :edit
    end
  end

  def destroy
    # 削除したいデータ取得
    display_format = DisplayFormat.find( params[ :id ] )
    display_format.destroy
    # 一覧ページへ
    redirect_to display_formats_path
  end

  private
  def display_format_params
    params.require( :display_format ).permit( :name, :alive, :dead, :font_color,
      :background_color, :line_height_rate )
  end

  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless DisplayFormat.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to display_formats_path
    end
  end
end
