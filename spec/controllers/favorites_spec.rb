require 'rails_helper'
# bundle exec rspec spec/controllers/favorites_spec.rb
RSpec.describe FavoritesController do
  # 自分のお気に入りレコード
  let!(:favorite){create(:favorite)}
  # 他人が作成したパターン
  let(:pattern){create(:pattern)}

  describe '非ログインユーザの場合' do
    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {pattern_id: pattern}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの登録に失敗' do
        expect do
          post :create, params: {pattern_id: pattern}, as: :js
        end.to_not change(Favorite, :count)
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: {pattern_id: favorite.pattern_id}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの削除に失敗' do
        expect do
          post :create, params: {pattern_id: favorite.pattern_id}, as: :js
        end.to_not change(Favorite, :count)
      end
    end
  end # describe '非ログインユーザの場合'

  describe 'ログインユーザの場合' do
    before do
      sign_in favorite.user
    end

    context 'POST #create' do
      it 'リクエストが成功' do
        post :create, params: {pattern_id: pattern}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの登録に成功' do # お気に入り登録
        expect do
          post :create, params: {pattern_id: pattern}, as: :js
        end.to change(Favorite, :count).by(1)
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが成功' do
        delete :destroy, params: { pattern_id: favorite.pattern_id }, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの削除に成功' do # お気に入り解除
        expect do
          delete :destroy, params: { pattern_id: favorite.pattern_id }, as: :js
        end.to change(Favorite, :count).by(-1)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe FavoritesController
