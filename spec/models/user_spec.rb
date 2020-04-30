require 'rails_helper'

RSpec.describe 'Userモデルのバリデーションテスト', type: :model do
  let(:user){ create(:user) }

  context 'nameカラム' do
    it '空欄でないこと' do
      user.name = ""
      expect(user.valid?).to eq false;
      user.name = " "
      expect(user.valid?).to eq false;
      user.name = "　"
      expect(user.valid?).to eq false;
    end
  end

  context 'introductionカラム' do
    it '512文字未満であること' do
      user.introduction = ?a * 512
      expect(user.valid?).to eq false;
    end
  end

end
