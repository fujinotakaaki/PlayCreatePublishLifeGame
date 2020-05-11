require 'rails_helper'

RSpec.describe FavoritesController do
  # 自分のアカウント
  let!(:user){create(:user)}
  # 他人の作成したパターン
  let!(:pattern){create(:pattern_random)}
  # 自分がお気に入りしたデータ
  let!(:my_favorites){create_list(:favorite, 3, user: user)}

  describe '非ログインユーザの場合' do
    context 'post #create' do
      it 'リクエストが失敗' do
        post :create, params: {pattern_id: pattern.id}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが増えないこと' do
        expect do
          post :create, params: {pattern_id: pattern.id}, as: :js
        end.to_not change(Favorite, :count)
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: { pattern_id: Favorite.take.pattern_id }, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが減らないこと' do
        expect do
          post :create, params: {pattern_id: Favorite.take.pattern_id}, as: :js
        end.to_not change(Favorite, :count)
      end
    end
  end # describe '非ログインユーザの場合'

  describe 'ログインユーザの場合' do
    before do
      sign_in user
    end

    context 'post #create' do
      it 'リクエストが成功' do
        post :create, params: {pattern_id: pattern.id}, as: :js
        expect(response).to have_http_status 200
      end

      it 'お気に入り登録できること' do
        expect do
          post :create, params: {pattern_id: pattern.id}, as: :js
        end.to change(Favorite, :count).by(1)
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが成功' do
        delete :destroy, params: { pattern_id: my_favorites.sample.pattern_id }, as: :js
        expect(response).to have_http_status 200
      end

      it 'お気に入り解除できること' do
        expect do
          delete :destroy, params: { pattern_id: my_favorites.sample.pattern_id }, as: :js
        end.to change(Favorite, :count).by(-1)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe FavoritesController
