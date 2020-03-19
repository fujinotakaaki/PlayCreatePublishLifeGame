class MakingsController < ApplicationController
  before_action :authenticate_user!
  before_action :baria_user, except: [ :edit ]
  # dbからJSへパターン情報を渡すための変換メソッドをインクルード
  include ApplicationHelper
  # 文字情報からdvへパターン情報を渡すための変換メソッドをインクルード
  include MakingsHelper

  def edit
    # 作成中のパターン取得or新規盤面の作成
    @making = Making.find_or_create_by( user_id: current_user.id )
    # パターンデータを、jsで扱えるようにデータを格納
    @making_pattern = pattern_conversion_to_js( @making, @making.making_rows.pluck( :binary_number ) )
    gon.push(
      # パターンを１次元配列に変換したものを格納（メソッドはApplicationHelper参照）
      pattern: @making_pattern
    )
  end

  def update
    @making = Making.find( params[:id] )
    puts 'updateが実行されました。'
    puts params.inspect
    # これで取得可能だわ
    puts params[:making_text].inspect
  end

  def destroy
  end

  private
  def making_params
    params.permit( :making ).permit( :margin_top, :margin_bottom, :margin_left, :margin_right )
  end

  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless Making.find( params[:id] ).user_id  == current_user.id then
      # 不一致 => 一覧ページへ
      redirect_to member_path( current_user )
    end
  end
end
