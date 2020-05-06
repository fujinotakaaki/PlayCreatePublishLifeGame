class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user, only: [ :edit, :update, :destroy ]
  # 閲覧数カウントアップ
  impressionist actions: [ :show ]

  def new
    # 作成中のパターンを取得
    making = current_user.making
    # 新規パターンの作成とパラメータの代入
    @pattern = Pattern.new( making.as_pattern )
    # ライフゲームのエミュレーション準備（新規パターンデータを使用）
    set_to_gon( @pattern )
  end

  def create
    @pattern = current_user.patterns.build( create_pattern_params )
    # エラーが発生すれば強制終了
    return unless @pattern.save
    # セッションのパターンリストの削除
    session.delete(:patterns_list)
    # 初期化するデータをピックアップ
    making = current_user.making
    # データを削除
    making.destroy
  end

  def index
    # 一覧画面に表示する投稿の取得（カテゴリー検索、キーワード検索含む）
    @patterns = Pattern.search_by( *search_params ).page( params[ :page ] ).includes( :user, :category ).reverse_order
    # 投稿一覧に表示する内容の取得
    @title, @title_detail = title_content( *search_params )
  end

  def edit
    @pattern = Pattern.find( params[ :id ] )
    # ライフゲームのエミュレーション準備
    set_to_gon( @pattern )
  end

  def show
    @pattern = Pattern.find( params[ :id ] )
    # ライフゲームのエミュレーション準備
    set_to_gon( @pattern )
    # このパターンに対し最近投稿されたコメント5件をピックアップ
    @latest_comments = @pattern.post_comments.reverse_order.limit(5)
    # 最近投稿されたカテゴリが同じパターン2件をピックアップ（ただし、自身は含まない）
    @sampling_patterns = @pattern.same_category_patterns(2)
    respond_to do |format|
      format.html
      format.json { render :json => @pattern.as_coupler }
    end
  end

  def update
    @pattern = Pattern.find( params[ :id ] )
    @pattern.update( update_pattern_params )
  end

  def destroy
    pattern = Pattern.find( params[ :id ] )
    pattern.destroy
    # セッションのパターンリストの削除
    session.delete(:patterns_list)
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
      params.require( :search ).permit( :category, :keyword ).to_h.shift
    end
  end

  # キーワード検索か判定（空文字の場合はfalse）
  def title_content( key = nil, value = nil )
    case key
      # 検索条件で分岐
    when 'category'
      # カテゴリー検索の場合
      category = Category.find(value)
      [ "カテゴリ：「#{category.name}」", category.explanation ]
    when 'keyword'
      # キーワード検索の場合
      "「#{value}」の検索結果"
    else
      # 検索条件なしの場合
      "全投稿"
    end
  end

end # class
