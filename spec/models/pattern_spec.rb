require 'rails_helper'

RSpec.describe 'Patternモデルのバリデーションテスト', type: :model do
  let(:pattern_block){ create(:pattern_block) }

  context 'nameカラム' do
    it '空欄でないこと' do
      pattern_block.name = ""
      expect(pattern_block.valid?).to eq false;
      pattern_block.name = " "
      expect(pattern_block.valid?).to eq false;
      pattern_block.name = "　"
      expect(pattern_block.valid?).to eq false;
    end
  end

  context 'introductionカラム' do
    it '512文字未満であること' do
      pattern_block.introduction = ?a * 512
      expect(pattern_block.valid?).to eq false;
    end
  end

end
