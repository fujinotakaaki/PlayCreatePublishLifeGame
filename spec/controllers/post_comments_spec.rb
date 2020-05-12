require 'rails_helper'
# bundle exec rspec spec/controllers/post_comments_spec.rb
RSpec.describe PostCommentsController do
  # 自分のアカウント
  let(:user){create(:user)}
  # 他人の作成したパターン
  let(:pattern){create(:pattern_random)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:comment)}

  describe '非ログインユーザの場合' do
    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {pattern_id: pattern, post_comment: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの登録に失敗' do
        expect do
          post :create, params: {pattern_id: pattern, post_comment: attributes_data}, as: :js
        end.to_not change(PostComment, :count)
      end
    end
  end # describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    before do
      sign_in user
    end

    context 'POST #create' do
      it 'リクエストが成功' do
        post :create, params: {pattern_id: pattern, post_comment: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの登録に成功' do
        expect do
          post :create, params: {pattern_id: pattern, post_comment: attributes_data}, as: :js
        end.to change(PostComment, :count).by(1)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe PostCommentsController
