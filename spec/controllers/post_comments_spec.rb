require 'rails_helper'

RSpec.describe PostCommentsController do
  # 自分のアカウント
  let!(:user){create(:user)}
  # 他人の作成したパターン
  let!(:pattern){create(:pattern_random)}
  # 自分がお気に入りしたデータ
  let!(:my_comments){create_list(:comment, 3, user: user)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:comment)}

  describe '非ログインユーザの場合' do
    context 'post #create' do
      it 'リクエストが失敗' do
        post :create, params: {pattern_id: pattern.id, post_comment: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが増えないこと' do
        expect do
          post :create, params: {pattern_id: pattern.id, post_comment: attributes_data}, as: :js
        end.to_not change(PostComment, :count)
      end
    end

  end # describe '非ログインユーザの場合'

  describe 'ログインユーザの場合' do
    before do
      sign_in user
    end

    context 'post #create' do
      it 'リクエストが成功' do
        post :create, params: {pattern_id: pattern.id, post_comment: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードが登録できること' do
        expect do
          post :create, params: {pattern_id: pattern.id, post_comment: attributes_data}, as: :js
        end.to change(PostComment, :count).by(1)
      end
    end

  end # describe 'ログインユーザの場合'
end # describe PostCommentsController
