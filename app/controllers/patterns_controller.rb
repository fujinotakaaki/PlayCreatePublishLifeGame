class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user, only: [ :edit, :update, :destroy ]
  # 閲覧数カウントアップ
  impressionist actions: [ :show ]
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ変換）
  include MakingsHelper
  # build_up_bit_strings_from, set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper


  def new
    # 作成中のパターンを取得
    making = Making.find_by( user_id: current_user.id )
    # 新規パターンの作成とパラメータの代入
    @pattern = Pattern.new( making.as_pattern )
    # gonに新規パターンデータを格納
    set_to_gon( @pattern )
  end

  def create
    @pattern = current_user.patterns.build( create_pattern_params )
    # エラーが発生すれば強制終了
    return unless @pattern.save
    # 初期化するデータをピックアップ
    making = Making.find_by( user_id: current_user.id )
    # データを削除
    making.destroy
  end

  def index
    # 一覧画面に表示する項目の条件の取得
    key, value = search_params
    # 一覧画面に表示する項目の取得
    @patterns, *@title = begin
      case key
        # 検索条件で分岐
      when 'category'
        # カテゴリー検索の場合
        category = Category.find(value)
        [
          category.patterns.page( params[ :page ] ).includes( :user ).reverse_order,
          "カテゴリ：「#{category.name}」", "「#{category.explanation}」"
        ]
      when search_keyword?( value )
        # キーワード検索の場合
        [
          Pattern.where( 'name LIKE ? or introduction LIKE ?', "%#{value}%", "%#{value}%" ).page( params[ :page ] ).includes( :user, :category ).reverse_order,
          "「#{value}」の検索結果"
        ]
      else
        # 全投稿表示の場合
        [
          Pattern.page( params[ :page ] ).includes( :user, :category ).reverse_order,
          "全投稿"
        ]
      end
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
    # このパターンに対し最近投稿されたコメント5件をピックアップ
    @latest_comments = @pattern.post_comments.reverse_order.limit(5)
    # 最近投稿されたカテゴリが同じパターン2件をピックアップ（自分を除く）
    @sampling_patterns = Pattern.where( 'category_id = ? and id != ?', @pattern.category_id, @pattern.id ).includes( :user, :category ).reverse_order.limit(2)
  end

  def update
    @pattern = Pattern.find( params[ :id ] )
    @pattern.update( update_pattern_params )
  end

  def destroy
    pattern = Pattern.find( params[ :id ] )
    pattern.destroy
    # マイページへ遷移
    redirect_to member_path( current_user )
  end


  private

  # オーナーとログインユーザの識別
  def baria_user
    # ログインユーザとオーナーが一致しているか判定
    unless Pattern.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => マイページへ
      redirect_to current_user
    end
  end

  # 新規投稿の際に取得するストロングパラメータ
  def create_pattern_params
    params.require( :pattern ).permit( :name, :introduction, :image, :category_id, :display_format_id,
      :margin_top, :margin_bottom, :margin_left, :margin_right, :is_torus, :normalized_rows_sequence )
  end

  # 更新の際に取得するストロングパラメータ
  def update_pattern_params
    params.require( :pattern ).permit( :name, :introduction, :image, :category_id, :display_format_id,
      :margin_top, :margin_bottom, :margin_left, :margin_right, :is_torus, :is_secret )
  end

  # 一覧表示の項目検索条件取得メソッド
  def search_params
    # カテゴリorキーワード検索の場合処理
    if params.has_key?( :search ) then
      params.require( :search ).permit( :category, :keyword ).to_hash.flatten
    end
  end

  # キーワード検索か判定（空文字の場合はfalse）
  def search_keyword?( value )
    -> key { ! value.blank? && key&.match?( 'keyword' ) }
  end
end # class
