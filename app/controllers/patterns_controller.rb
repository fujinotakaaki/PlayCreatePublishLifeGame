class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]
  # build_up_data_fromメソッドをインクルード（ビット列 => dbデータへ）
  include MakingsHelper
  # build_up_bit_strings_fromメソッドをインクルード（dbデータ=> ビット列へ）
  include PatternsHelper


  def new
    # 作成中パターンのテキストデータを受け取り、配列に変換
    bit_strings_array = params[:making_pattern].split( ?, )
    # 配列化したパターンをgonに格納
    gon.push(
      # パターンを１次元配列に変換したものを格納
      pattern: bit_strings_array
    )
    # dbに保存するためのデータに変換
    pattern_params, binary_numbers = build_up_data_from( bit_strings_array.join( "\n" ) )
    @pattern = current_user.patterns.new( pattern_params )
    binary_numbers.each do | binary_number |
      @pattern.pattern_rows.build( binary_number: binary_number )
    end
  end

  def create
    @pattern = current_user.patterns.build( create_pattern_params )
    @pattern.save
  end

  def index
    # ページングの設定はconfig/initializers/kaminari_config.rb
    if  !!params[ :category_id ] then
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
    # このパターンに対していちばん最近投稿されたコメントをピックアップ
    @latest_comment = PostComment.order(created_at: :desc).find_by( pattern_id: params[ :id ] )
    # いちばん最近投稿されたカテゴリが同じパターンをピックアップ（自分がそうだったら２番目）
    @latest_same_category_pattern_sample = Pattern.where( 'category_id = ? and id != ?', @pattern.category_id, @pattern.id ).last
    # パターンデータを、jsで扱えるようにデータを格納
    gon.push(
      # パターンを１次元配列に変換したものを格納
      pattern: build_up_bit_strings_from( @pattern, @pattern.pattern_rows.pluck( :binary_number ) ),
      # 表示形式の格納
      displayFormat: @pattern.display_format,
      # 平坦トーラス面として扱うか
      isTorus: @pattern.is_torus
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
    params.require( :pattern ).permit( :name, :introduction, :image, :margin_top, :margin_bottom, :margin_left, :margin_right,
      pattern_rows_attributes: [:binary_number] )
  end

  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless Pattern.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to current_user
    end
  end
end # class
