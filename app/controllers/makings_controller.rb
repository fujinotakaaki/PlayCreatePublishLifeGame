class MakingsController < ApplicationController
  before_action :authenticate_user!

  def new
    # 画像からパターンを作成する
  end

  def create
    # 画像から作成したパターンデータに更新する
    update{ | making_params | making_params.merge!( { display_format_id: 2 } ) }
    # パターン投稿ページへ
    redirect_to edit_making_path
  end

  def edit
    # 作成中のパターン取得or新規盤面の作成
    @making = Making.find_or_create_by( user_id: current_user.id )
    # 全パターンのパターン名とIDを取得（ログインしている間は再取得しない）
    @patterns_list = session[:patterns_list] ||= Pattern.pluck( :name, :id ).to_h
    # ライフゲームのエミュレーション準備（作成中のパターンを使用）
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
    # cereateから呼ばれている場合はdisplay_format_idを2に更新する
    yield making_params if block_given?
    # 更新実行
    @making.update( making_params )
  end

  def destroy
    # 初期化するデータをピックアップ
    making = current_user.making
    # データを削除
    making.destroy
    # 編集ページへ戻る
    redirect_to edit_making_path
  end


  private

  def update_params
    # 送信されてきたデータから必要なパラメータを抽出
    raw_params = params.require( :making ).permit( :display_format_id, :transform_scale_rate, :is_torus, :making_text )
    # :making_textデータから、:margin_XXXと:normalized_rows_sequenceに変換・取得する。
    # パラメータ（Hash）orエラーメッセージ(String)を受け取る
    convert_params = build_up_pattern_params_from( raw_params.delete( :making_text ) )
    # エラーがあった場合はエラーメッセージを返す
    return convert_params unless convert_params.is_a?( Hash )
    # ストロングパラメータにマージして返す
    raw_params.merge( convert_params )
  end
end
