require 'rails_helper'

RSpec.describe MembersController do
  amounts_per_page = Kaminari.config.default_per_page
  # 自分のアカウント
  let!(:user){create(:user)}
  # 自分の投稿データ
  let!(:my_patterns){create_list(:pattern_random, rand(3..6), user: user)}
  # 自分のお気に入り投稿データ
  let!(:my_favorites){create_list(:favorite, rand(3..6), user: user)}

  # 他人のアカウント
  let!(:another_user){create(:user)}
  # 他人の投稿データ
  let!(:anothers_patterns){create_list(:pattern_random, rand(3..6), user: another_user)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:user)}

  describe '非ログインユーザの場合' do
    context 'get #confirm' do
      it 'リクエストが失敗' do
        get :confirm, params: {id: User.take}
        expect(response).to have_http_status 302
      end
    end

    context 'get #edit' do
      it 'リクエストが失敗' do
        get :confirm, params: {id: User.take}, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'get #show' do
      it 'リクエストが成功' do
        get :show, params: {id: User.take, page: rand(1..2)}
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        user_sample = User.take
        _params = {id: user_sample, page: rand(1..2)}
        get :show, params: _params
        expect(assigns :user).to eq user_sample
        expect(assigns :patterns).to eq user_sample.patterns.limit(amounts_per_page).offset(amounts_per_page*(_params[:page]-1)).reverse_order
        expect(assigns :title).to eq 'ユーザ投稿'
      end
    end

    context 'patch #update' do
      it 'リクエストが失敗' do
        user_sample = User.take
        patch :update, params: {id: user_sample, user: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの更新に失敗' do
        user_sample = User.take
        expect(user_sample.name).to_not eq attributes_data[:name]
        patch :update, params: {id: user_sample, user: attributes_data}, as: :js
        expect(user_sample.reload.name).to_not eq attributes_data[:name]
      end
    end
  end # describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    before do
      sign_in user
    end

    context 'get #confirm' do
      it '自分のページへのリクエストが成功' do
        get :confirm, params: {id: user}
        expect(response).to have_http_status 200
      end

      it '他人のページへのリクエストが失敗' do
        get :confirm, params: {id: another_user}
        expect(response).to have_http_status 302
      end
    end

    context 'get #edit' do
      it '自分のページへのリクエストが成功' do
        get :confirm, params: {id: user}, as: :js
        expect(response).to have_http_status 200
      end

      it '他人のページへのリクエストが失敗' do
        get :confirm, params: {id: another_user}, as: :js
        expect(response).to have_http_status 302
      end
    end

    context 'get #show' do
      context '自分の投稿一覧について' do
        it '自分のページへのリクエストが成功' do
          get :show, params: {id: user, page: rand(1..2)}
          expect(response).to have_http_status 200
        end

        it '適切なレコードを取得' do
          _params = {id: user, page: rand(1..2)}
          get :show, params: _params
          expect(assigns :user).to eq user
          expect(assigns :patterns).to eq user.patterns.limit(amounts_per_page).offset(amounts_per_page*(_params[:page]-1)).reverse_order
          expect(assigns :title).to eq 'ユーザ投稿'
        end
      end

      context '自分のお気に入り一覧について' do
        it '自分のページへのリクエストが成功' do
          get :show, params: {id: user, favorite: true, page: rand(1..2)}
          expect(response).to have_http_status 200
        end

        it '適切なレコードを取得' do
          _params = {id: user, favorite: true, page: rand(1..2)}
          get :show, params: _params
          expect(assigns :user).to eq user
          expect(assigns :patterns).to eq user.favorite_patterns.limit(amounts_per_page).offset(amounts_per_page*(_params[:page]-1)).reverse_order
          expect(assigns :title).to eq 'お気に入り'
        end
      end
    end # context 'get #show'

    context 'patch #update' do
      it '自分のページへのリクエストが成功' do
        patch :update, params: {id: user, user: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it '自分のレコードの更新に成功' do
        expect(user.name).to_not eq attributes_data[:name]
        patch :update, params: {id: user, user: attributes_data}, as: :js
        expect(user.reload.name).to eq attributes_data[:name]
      end

      it '他人のレコードの更新に失敗' do
        expect(another_user.name).to_not eq attributes_data[:name]
        patch :update, params: {id: another_user, user: attributes_data}, as: :js
        expect(another_user.reload.name).to_not eq attributes_data[:name]
        expect(response).to have_http_status 302
      end
    end
  end # describe 'ログインユーザの場合'
end # describe MembersController
