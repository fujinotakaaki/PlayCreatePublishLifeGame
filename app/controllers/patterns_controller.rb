class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ変換）
  include MakingsHelper
  # build_up_bit_strings_from, set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper


  def new
    # テキスト化されているパターンデータを配列にする
    concated_bit_strings = params[:making_pattern]
    # トーラス面設定の取得
    bool = /true/.match?( params[:is_torus] )
    # パターン形成に関する必要項目をあらかじめ入力
    @pattern = Pattern.new( build_up_pattern_params_from( concated_bit_strings ).merge( { is_torus: bool } ) )
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
    @patterns = begin
      # 検索条件で分岐
      case key
      when search_category? then
        # カテゴリー検索の場合
        Pattern.where( category_id: value ).page( params[ :page ] ).reverse_order
      when search_keyword?( value ) then
        # キーワード検索の場合
        Pattern.where( 'name LIKE ? or introduction LIKE ?', "%#{value}%", "%#{value}%" ).page( params[ :page ] ).reverse_order
      else
        # 全投稿表示の場合
        Pattern.page( params[ :page ] ).reverse_order
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
    @latest_comments = PostComment.where( pattern_id: params[ :id ] ).reverse_order.limit(5)
    # 最近投稿されたカテゴリが同じパターン2件をピックアップ（自分を除く）
    @sampling_patterns = Pattern.where( 'category_id = ? and id != ?', @pattern.category_id, @pattern.id ).reverse_order.limit(2)
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

      # 一覧表示の項目検索条件取得メソッド
      def search_params
        begin
          params.require( :search ).permit( :category, :keyword ).to_hash.flatten
        rescue => e
          # puts e
        end
      end

      # カテゴリ検索か判定
      def search_category?
        -> key { key&.match?( 'category' ) }
      end

      # キーワード検索か判定（空文字の場合はfalse）
      def search_keyword?( value )
        -> key { ! value.blank? && key&.match?( 'keyword' ) }
      end
    end # class
