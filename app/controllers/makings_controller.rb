class MakingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    # 作成中のパターン取得or新規盤面の作成
    @making = Making.find_or_create_by( user_id: current_user.id )
  end

  def update
    # 作成中のパターンの読み込み
    @making = Making.find( current_user.id )
    # ！工事中！バリデーション をかけるが、どちらも遷移先は同じ！工事中！
    if @making.update( making_params ) then
      # 成功 => 元のページへ
      redirect_to edit_making_path
    else
      # 失敗 =>  編集ページへもどる
      render :edit
    end
  end

  def destroy
    # 作成中のパターンの読み込み
    @making = set_making
    @making.destroy
    # 新規作成
    @making = set_making
  end

  private
  def making_params
    params.permit( :making ).permit( :margin_top, :margin_bottom, :margin_left, :margin_right )
  end
end
