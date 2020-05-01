require 'rails_helper'

RSpec.describe 'Patternsヘルパーのテスト', type: :helper do
  let(:pattern_block){ create(:pattern_block) }

  context 'build_up_bit_strings_fromメソッド' do
    it 'パターンの構築が正しくできていること' do
      bit_strings = helper.build_up_bit_strings_from pattern_block
      expect(bit_strings).to eq [ '0000', '0110', '0110', '0000'];
    end
  end

end
