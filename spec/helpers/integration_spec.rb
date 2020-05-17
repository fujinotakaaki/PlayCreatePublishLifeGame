# データ変換のテスト
# '010\n001\n111' => making_params =>'010\n001\n111'
# making_params = {
#   :margin_top=>0,
#   :margin_bottom=>0,
#   :margin_left=>0,
#   :margin_right=>0,
#   :normalized_rows_sequence=>"2,1,7"
# }

require 'rails_helper'
# bundle exec rspec spec/helpers/integration_spec.rb
RSpec.describe "MakingヘルパーとPatternヘルパーの統合テスト", type: :helper do
  let(:making_text){attributes_for(:making, :filled_random)[:making_text]}
  context 'ライフゲームパターン => レコードに変換 => パターンを再構築'
  1.times do |i|
    it "#{i+1}回目のテスト" do
      # 生データの照会
      # p making_text
      # 生データからパラメータ構築
      making_params = helper.build_up_pattern_params_from making_text
      # パラメータ（Hash）か確認（エラーメッセージでないこと）
      expect(Hash).to be === making_params
      # ライフゲーム用のビット列の配列を構築
      building_lifegame_pattern_array = helper.build_up_bit_strings_from Making.new(making_params)
      # 投入データと完全に一致するか判定
      expect(building_lifegame_pattern_array.join("\n")).to eq making_text
    end
  end
end
