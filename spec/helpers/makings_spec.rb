require 'rails_helper'

RSpec.describe 'Makingヘルパーのテスト', type: :helper do
  context 'build_up_bit_strings_fromメソッド' do
    it 'テキストデータからパラメータの構築が正しくできていること' do
      octagon = <<~TEXT
      0000000000
      0000000000
      0001001000
      0010110100
      0001001000
      0001001000
      0010110100
      0001001000
      0000000000
      0000000000
      TEXT

      making_params = helper.build_up_pattern_params_from octagon
      expect(Hash).to be === making_params
      expect(making_params[:margin_top]).to eq 2
      expect(making_params[:margin_bottom]).to eq 2
      expect(making_params[:margin_left]).to eq 2
      expect(making_params[:margin_right]).to eq 2
      expect(making_params[:normalized_rows_sequence]).to eq '12,2d,12,12,2d,12'
    end

    it 'セルの幅が不一致の場合はエラーメッセージが返されること' do
      incomplete_block_pattern = <<~TEXT
      0000
      011
      0110
      0000
      TEXT
      making_params = helper.build_up_pattern_params_from incomplete_block_pattern
      expect(making_params).to eq 'パターンの幅が不揃いです。'
    end

    it '「生」のセルが無い場合はエラーメッセージが返されること' do
      no_alive_patten = <<~TEXT
      0000
      0000
      0000
      0000
      TEXT
      making_params = helper.build_up_pattern_params_from no_alive_patten
      expect(making_params).to eq '「生」状態のセルがありません。'
    end

    it 'セルが一つも無い場合はエラーメッセージが返されること' do
      no_cells_pattern = ""
      making_params = helper.build_up_pattern_params_from no_cells_pattern
      expect(making_params).to eq 'セルがありません。'
    end

    # 全てパターンが不揃いとして扱われる
    it '0と1と区切り以外の文字が含まれる場合はエラーメッセージが返されること' do
      abnormal_pattern = <<~TEXT
      0000
      011e
      0110
      0000
      TEXT
      making_params = helper.build_up_pattern_params_from abnormal_pattern
      expect(String).to be === making_params

      abnormal_pattern = <<~TEXT
      0000
      0110
      0ab0
      0000
      TEXT
      making_params = helper.build_up_pattern_params_from abnormal_pattern
      expect(String).to be === making_params

      abnormal_pattern = <<~TEXT
      0000
      0110
      abnormal_pattern
      0000
      TEXT
      making_params = helper.build_up_pattern_params_from abnormal_pattern
      expect(String).to be === making_params
    end

  end
end
