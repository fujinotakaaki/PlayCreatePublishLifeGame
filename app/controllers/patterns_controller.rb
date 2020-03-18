class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]

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
    @latest_comment = PostComment.order(created_at: :desc).find_by( pattern_id: params[ :id ] )
    # jsでパターンデータを扱うための変数とデータを格納
    gon.push(
      # パターンを１次元配列に変換したものを格納
      pattern: pattern_conversion_to_js( @pattern, @pattern.pattern_rows.pluck( :binary_number ) ),
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
  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless Pattern.find( params[ :id ] ).user_id  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to current_user
    end
  end

  # dbのパターン情報をJSのライフゲーム用のデータに変換するメソッド
  def pattern_conversion_to_js( pattern, rows )
    # 最も大きい2進数を取得
    largest_number = rows.max
    # 最も大きい2進数の桁数を算出（但し、0b0なら1桁とする）
    largest_number_bit_length = largest_number.zero? ? 1 : ( Math.log2( largest_number ) + 1 ).to_i
    # 左右の余白を含めたマップ幅を計算
    pattern_bit_length = pattern.margin_left + largest_number_bit_length + pattern.margin_right
    # jsでパターンを扱うための変数作成
    pattern_js = Array.new
    # 上側マージン挿入（不具合予防のため深いコピーで作成）
    pattern_js += Array.new( pattern.margin_top ){ ?0 * pattern_bit_length }
    # パターンを配列に格納していく
    rows.each do | binary_number |
      pattern_js.push( ?0 * pattern.margin_left + ( "%0#{largest_number_bit_length}b" % binary_number ) + ?0 * pattern.margin_right )
    end
    # 下側マージンの挿入（不具合予防のため深いコピーで作成）
    pattern_js += Array.new( pattern.margin_bottom ){ ?0 * pattern_bit_length }
    # js用パターンデータを返す
    return pattern_js
  end
end # class
