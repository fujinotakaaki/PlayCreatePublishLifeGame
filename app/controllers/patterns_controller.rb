class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ）
  include MakingsHelper
  # build_up_bit_strings_fromメソッドをインクルード（dbデータ=> ビット列へ）
  include PatternsHelper


  def new
    # テキスト化されているパターンデータを配列にする
    bit_string_array = params[:making_pattern].split( ?, )
    # パターン形成に関する必要項目をあらかじめ入力
    @pattern = current_user.patterns.new( build_up_pattern_params_from( bit_string_array ) )
    # 配列化したパターンをgonに格納
    gon.push(
      # パターンを１次元配列に変換したものを格納
      pattern: bit_string_array
    )
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
  end

  def show
    @pattern = Pattern.find( params[ :id ] )
    display_format = @pattern.display_format
    # このパターンに対していちばん最近投稿されたコメントをピックアップ
    @latest_comments = PostComment.order(created_at: :desc).where( pattern_id: params[ :id ] ).limit(5)
    # 最近投稿されたカテゴリが同じパターン2件をピックアップ（自分を除く）
    @sampling_patterns = Pattern.order(created_at: :desc).where( 'category_id = ? and id != ?', @pattern.category_id, @pattern.id ).limit(2)
    # パターンデータを、jsで扱えるようにデータを格納
    gon.push(
      # パターンを１次元配列に変換したものを格納
      pattern: build_up_bit_strings_from( @pattern ),
      # cssの設定
      cssOptions: display_format.as_json_css_options,
      # セルの表示定義設定
      cellConditions: display_format.as_json_cell_conditions( @pattern.is_torus )
    )
  end

  def update
    @pattern = Pattern.find( params[ :id ] )
  end

  def destroy
    @pattern = Pattern.find( params[ :id ] )
  end

  private
  def create_pattern_params
    params.require( :pattern ).permit( :name, :introduction, :image, :category_id, :display_format_id, :margin_top,
      :margin_bottom, :margin_left, :margin_right, :is_torus, :normalized_rows_sequence )
  end

  def update_pattern_params
    params.require( :pattern ).permit( :name, :introduction, :image, :category_id, :display_format_id, :is_torus, :is_secret )
  end

  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless Pattern.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to current_user
    end
  end
end # class
