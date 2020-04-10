class HomesController < ApplicationController
  # set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper


  def top
    # ライフゲームのエミュレーション準備
    set_to_gon
  end

  def about
  end
end
