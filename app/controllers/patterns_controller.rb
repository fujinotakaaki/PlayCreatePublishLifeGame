class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :baria_user,                  only: [ :edit, :update, :destroy ]
  include ApplicationHelper

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
      # パターンを１次元配列に変換したものを格納（メソッドはApplicationHelper参照）
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
end # class
