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
    # パターンデータを、jsで扱えるようにデータを格納
    gon.push(
      # パターンを１次元配列に変換したものを格納（メソッドはApplicationHelper参照）
      pattern: @making_pattern
    )
  end

  def update
    # パターンの上下左右の余白、各行の数値化配列を受け取る
    # （エラーが発生した時は第１引数はnilを、第２引数はエラーメッセージを格納）
    making_params, making_row_integers = convert_text_for_db_data( params[ :making_text ] )
    # テキストデータが正常に変換されたかチェック
    if making_params.nil? then
      # 第２引数のエラーメッセージを格納
      @convertion_error_message = making_row_integers
      return
    end
    # データ更新を実施するデータをピックアップ
    @making = Making.find( params[:id] )
    # 更新実行
    if @making.update( making_params ) then
      # 更新前の行データを削除する
      @making.making_rows&.destroy_all
      # 更新後のパターンの行データを保存する
      making_row_integers.each do | natural_number |
        MakingRow.new( making_id: params[:id], binary_number: natural_number ).save
      end
      # 更新後のパターンデータ
      @update_making_pattern = pattern_conversion_to_js( @making, making_row_integers )
    end
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
