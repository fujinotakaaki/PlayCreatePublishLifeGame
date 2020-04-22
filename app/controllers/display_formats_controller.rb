class DisplayFormatsController < ApplicationController
  before_action :authenticate_user!
  before_action :baria_user, only: [ :edit, :update, :destroy ]

  def new
    @display_format = DisplayFormat.new
    # ログインユーザの投稿したセルの表示形式を全件取得
    @display_formats = current_user.display_formats
    # ライフゲームのエミュレーション準備
    # 初期パターンはウェルカムメッセージのパターンとする
    set_to_gon( nil, @display_format )
  end

  def create
    @display_format = current_user.display_formats.build( display_format_params )
    @display_format.save
  end

  # 非同期通信（Patterns#new, #editで使用）
  def show
    display_format = DisplayFormat.find( params[ :id ] )
    # 所定のデータ形式に変換
    display_format_as_json = {
      # cssの設定
      cssOptions:   display_format.as_json_css_options,
      # セルの表示定義設定
      cellConditions: display_format.as_json_cell_conditions,
    }
    # jsonデータを返す
    render json: display_format_as_json
  end

  def edit
    @display_format = DisplayFormat.find( params[ :id ] )
    # 編集データが使われているパターンを1個取得（自分が作成したものに限定）
    sample_pattern = Pattern.find_by( display_format_id: params[ :id ], user_id: current_user.id )
    # ライフゲームのエミュレーション準備
    # 第１引数のパターンが存在しない場合を考慮し、第２引数の指定必要あり
    set_to_gon( sample_pattern, @display_format )
  end

  def update
    @display_format = DisplayFormat.find( params[ :id ] )
    @display_format.update( display_format_params )
  end

  def destroy
    display_format = DisplayFormat.find( params[ :id ] )
    display_format.destroy
    # マイページへ
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
      # 不一致 => TOPへ
      redirect_to root_path
    end
  end
end
