require 'rails_helper'

RSpec.describe 'PostCommentモデルのバリデーションテスト', type: :model do
  let(:post_comment){ create(:comment) }

  context 'bodyカラム' do
    it '空欄でないこと' do
      post_comment.body = ""
      expect(post_comment.valid?).to eq false
      post_comment.body = " "
      expect(post_comment.valid?).to eq false
      post_comment.body = "　"
      expect(post_comment.valid?).to eq false
    end

    it '512文字未満であること' do
      post_comment.body = ?a * 512
      expect(post_comment.valid?).to eq false
    end
  end

end
