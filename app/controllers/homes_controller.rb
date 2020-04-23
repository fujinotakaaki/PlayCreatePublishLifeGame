class HomesController < ApplicationController

  def top
    # 現在のページ情報を追記
    gon.page = "top"
    # ライフゲームのエミュレーション準備
    set_to_gon
  end

  def about
  end

  def jump
    redirect_to root_path
  end
end
