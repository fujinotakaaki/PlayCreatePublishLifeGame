class HomesController < ApplicationController

  def top
    # ライフゲームのエミュレーション準備
    set_to_gon
  end

  def about
  end

  def jump
    redirect_to root_path
  end
end
