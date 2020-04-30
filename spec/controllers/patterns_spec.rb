require 'rails_helper'

RSpec.describe 'Patternコントローラのテスト', type: :controller do
  include PatternsHelper
  let(:pattern_block){ create(:block) }

  context 'パターン構築' do
    it '「ブロック」が構築が正しくできていること' do
      pattern_block_arr = build_up_bit_strings_from pattern_block
      pattern_block_answer = [ '0000', '0110', '0110', '0000']
      expect(pattern_block_arr).to eq pattern_block_answer;
    end
  end

end
