require 'rails_helper'

RSpec.describe 'Patternモデルのバリデーションテスト', type: :model do
  let(:block){ create(:block) }

  context 'nameカラム' do
    it '空欄でないこと' do
      block.name = ""
      expect(block.valid?).to eq false
      block.name = " "
      expect(block.valid?).to eq false
      block.name = "　"
      expect(block.valid?).to eq false
    end
  end

  context 'introductionカラム' do
    it '512文字未満であること' do
      block.introduction = ?a * 512
      expect(block.valid?).to eq false
    end
  end

end
