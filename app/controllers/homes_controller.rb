class HomesController < ApplicationController
  # set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper

  def top
    # トップページに表示するパターン
    top_pattern = Pattern.new({
      display_format_id: 1,
      is_torus: true,
      margin_top: 2,
      margin_bottom: 3,
      margin_left: 4,
      margin_right: 5,
      normalized_rows_sequence: "2a08000050,2a48000250,2aa9990550,2aea25a750,2a8a255400,1469995350,0,0,10300e0000,1120110000,1072200002,1125200105,11272391a7,112411a954,1d230e9553"
      })
      set_to_gon( top_pattern )
    end

  def about
  end
end
