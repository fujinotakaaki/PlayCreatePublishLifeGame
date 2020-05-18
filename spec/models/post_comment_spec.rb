require 'rails_helper'

RSpec.describe 'PostCommentモデルのバリデーションテスト', type: :model do
  let(:comment){ create(:comment) }

  context 'bodyカラム' do
    it '空欄でないこと' do
      comment.body = ""
      expect(comment.valid?).to eq false
      comment.body = " "
      expect(comment.valid?).to eq false
      comment.body = "　"
      expect(comment.valid?).to eq false
    end

    it '512文字未満であること' do
      comment.body = ?a * 512
      expect(comment.valid?).to eq false
    end
  end

end
