class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user, only: [ :edit, :update, :destroy ]
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ変換）
  include MakingsHelper
  # build_up_bit_strings_from, set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper


  def new
    # パラメータの構築
    precreate_params = build_up_pattern_params_from( params[:making_pattern] )
    # 新規パターンの作成とパラメータの代入
    @pattern = Pattern.new( precreate_params )
    # トーラス面設定の取得・代入
    @pattern.is_torus = /true/.match?( params[:is_torus] )
    # gonにデータを格納
    set_to_gon( @pattern )
  end

  def create
    @pattern = current_user.patterns.build( create_pattern_params )
    @pattern.save
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
          category.patterns.page( params[ :page ] ).includes( :user, :favorites, :post_comments ).reverse_order,
          "カテゴリ：「#{category.name}」", "「#{category.explanation}」"
        ]
      when search_keyword?( value )
        # キーワード検索の場合
        [
          Pattern.where( 'name LIKE ? or introduction LIKE ?', "%#{value}%", "%#{value}%" ).page( params[ :page ] ).includes( :user, :category, :favorites, :post_comments ).reverse_order,
          "「#{value}」の検索結果"
        ]
      else
        # 全投稿表示の場合
        [
          Pattern.page( params[ :page ] ).includes( :user, :category, :favorites, :post_comments ).reverse_order,
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
    @latest_comments = PostComment.where( pattern_id: params[ :id ] ).includes( :user ).reverse_order.limit(5)
    # 最近投稿されたカテゴリが同じパターン2件をピックアップ（自分を除く）
    @sampling_patterns = Pattern.where( 'category_id = ? and id != ?', @pattern.category_id, @pattern.id ).includes( :category ).reverse_order.limit(2)
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

  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless Pattern.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => マイページへ
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

  # 一覧表示の項目検索条件取得メソッド
  def search_params
    begin
      # カテゴリorキーワード検索の場合
      params.require( :search ).permit( :category, :keyword ).to_hash.flatten
    rescue => e
      # 全投稿検索の場合
      # logger.debug e
    end
  end

  # キーワード検索か判定（空文字の場合はfalse）
  def search_keyword?( value )
    -> key { ! value.blank? && key&.match?( 'keyword' ) }
  end
end # class
