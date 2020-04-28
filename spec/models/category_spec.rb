require 'rails_helper'

RSpec.describe 'Categoryモデルのバリデーションテスト', type: :model do
  let(:category){ create(:category) }

  context 'nameカラム' do
    it '空欄でないこと' do
      category.name = String.new
      expect(category.valid?).to eq false;
    end
  end

  context 'explanationカラム' do
    it '空欄でないこと' do
      category.explanation = String.new
      expect(category.valid?).to eq false;
    end
    it '512文字未満であること' do
      category.explanation = ?a * 512
      expect(category.valid?).to eq false;
    end
  end

end
