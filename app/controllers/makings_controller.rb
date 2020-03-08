class MakingsController < ApplicationController
  before_action :authenticate_user!
  
  def edit
    # 作成中のパターンの読み込みor新規作成
    @making = set_making
  end

  def update
    # 作成中のパターンの読み込み
    @making = set_making
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

  def set_making
    # 作成中のパターン取得or新規盤面の作成
     current_user.making || ( current_user.build_making.save && current_user.making )
  end
end
