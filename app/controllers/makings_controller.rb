class MakingsController < ApplicationController
  before_action :authenticate_user!
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ変換）
  include MakingsHelper
  # build_up_bit_strings_from, set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper


  def edit
    # 作成中のパターン取得or新規盤面の作成
    @making = Making.find_or_create_by( user_id: current_user.id )
    # gonにデータを格納
    set_to_gon( @making )
  end

  def update
    # データ更新を実施するデータをピックアップ
    @making = Making.find_by( user_id: current_user.id )
    # ストロングパラメータ取得（エラーがあればエラーメッセージを取得）
    making_params = update_params
    # エラーメッセージかチェック
    unless making_params.is_a?( ActionController::Parameters ) then
      # エラーメッセージを格納
      @convertion_error_message = making_params
      # 強制終了
      return
    end
    # 更新実行
    @making.update( making_params )
  end

  def destroy
    # 初期化するデータをピックアップ
    making = Making.find_by( user_id: current_user.id )
    # データを削除
    making.destroy
    # 編集ページへ戻る
    redirect_to edit_making_path
  end


  private

  def update_params
    # 送信されてきたデータから必要なパラメータを抽出
    raw_params = params.require( :making ).permit( :is_torus, :making_text )
    # :making_textデータを余白とパターンの行データ数列に変換する。
    # パラメータ（Hash）orエラーメッセージ(String)を受け取る
    convert_params = build_up_pattern_params_from( raw_params.delete( :making_text ) )
    # エラーがあった場合はエラーメッセージを返す
    return convert_params unless convert_params.is_a?( Hash )
    # ストロングパラメータにマージして返す
    raw_params.merge( convert_params )
  end
end
