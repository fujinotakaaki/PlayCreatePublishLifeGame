class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ変換）
  include MakingsHelper
  # build_up_bit_strings_from, set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper


  def new
    # テキスト化されているパターンデータを配列にする
    bit_string_array = params[:making_pattern].split( ?, )
    # トーラス面設定の取得
    bool = /true/.match?( params[:is_torus] )
    # パターン形成に関する必要項目をあらかじめ入力
    @pattern = Pattern.new( build_up_pattern_params_from( bit_string_array ).merge( { is_torus: bool } ) )
    # gonにデータを格納
    set_to_gon( @pattern )
  end

  def create
    @pattern = current_user.patterns.build( create_pattern_params )
    @pattern.save
  end

  def index
    # ページングの設定はconfig/initializers/kaminari_config.rb
    if  !! params[ :category_id ] then
      # カテゴリー別表示をする場合
      @patterns = Pattern.where( category_id: params[ :category_id ] ).page( params[ :page ] ).reverse_order
    else
      # 全表示をする場合
      @patterns = Pattern.page( params[ :page ] ).reverse_order
    end
  end

  def edit
    @pattern = Pattern.find( params[ :id ] )
    # gonにデータを格納
    set_to_gon( @pattern )
  end

  def show
    @pattern = Pattern.find( params[ :id ] )
    # gonにデータを格納
    set_to_gon( @pattern )
    # このパターンに対していちばん最近投稿されたコメントをピックアップ
    @latest_comments = PostComment.order(created_at: :desc).where( pattern_id: params[ :id ] ).limit(5)
    # 最近投稿されたカテゴリが同じパターン2件をピックアップ（自分を除く）
    @sampling_patterns = Pattern.order(created_at: :desc).where( 'category_id = ? and id != ?', @pattern.category_id, @pattern.id ).limit(2)
  end

  def update
    @pattern = Pattern.find( params[ :id ] )
    @pattern.update( update_pattern_params )
  end

  def destroy
    pattern = Pattern.find( params[ :id ] )
    pattern.destroy
    redirect_to member_path( current_user )
  end
  

  private
  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless Pattern.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to current_user
    end
  end

  def create_pattern_params
    params.require( :pattern ).permit( :name, :introduction, :image, :category_id, :display_format_id,
      :margin_top, :margin_bottom, :margin_left, :margin_right, :is_torus, :normalized_rows_sequence )
  end

  def update_pattern_params
    params.require( :pattern ).permit( :name, :introduction, :image, :category_id, :display_format_id,
      :margin_top, :margin_bottom, :margin_left, :margin_right, :is_torus, :is_secret )
  end
end # class
