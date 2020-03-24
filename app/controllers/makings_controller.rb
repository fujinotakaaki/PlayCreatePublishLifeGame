class MakingsController < ApplicationController
  before_action :authenticate_user!
  before_action :baria_user, except: [ :edit ]
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ変換）
  include MakingsHelper
  # build_up_bit_strings_fromメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper

  def edit
    # 作成中のパターン取得or新規盤面の作成
    @making = Making.find_or_create_by( user_id: current_user.id )
    # パターンデータを、jsで扱えるようにデータを格納
    @making_bit_strings_array = build_up_bit_strings_from( @making )
    # パターンデータを、jsで扱えるようにデータを格納
    gon.push(
      # パターンを１次元配列に変換したものを格納（メソッドはApplicationHelper参照）
      pattern: @making_bit_strings_array
    )
  end

  def update
    # （エラーが発生した時はエラーメッセージが格納される）
    making_params = build_up_pattern_params_from( params[ :making_text ].split )

    # テキストデータが正常に変換されたかチェック
    if String === making_params then
      # エラーメッセージを格納
      @convertion_error_message = making_params
      # 処理を強制終了
      return
    end

    # データ更新を実施するデータをピックアップ
    @making = Making.find( params[:id] )
    # 更新実行
    @making.update( making_params )
  end

  def destroy
  end

  private
  def baria_user
    # ログインユーザと製作者が一致しているか判定
    unless Making.find( params[:id] ).user_id  == current_user.id then
      # 不一致 => ユーザ詳細ページへ
      redirect_to member_path( current_user )
    end
  end
end
