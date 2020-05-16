require 'rails_helper'
# bundle exec rspec spec/controllers/members_spec.rb
RSpec.describe MembersController do
  # kaminariの１ページあたりのレコード取得数
  let(:amounts_per_page){Kaminari.config.default_per_page}
  # 自分のアカウント
  let!(:user){create(:user)}
  # 他人のアカウント
  let!(:another_user){create(:user)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:user, :edit)}

  describe '非ログインユーザの場合' do
    context 'GET #confirm' do
      it 'リクエストが失敗' do
        get :confirm, params: {id: user}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #edit' do
      it 'リクエストが失敗' do
        get :edit, xhr: true, params: {id: user}, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'GET #show' do
      # ユーザの投稿一覧データ作成とページ設定
      before do
        # 作成するレコード数
        # 自分の投稿
        n1 = rand(3..20)
        create_list(:pattern_random, n1, user: user)
        # 自分がお気に入りした投稿
        n2 = rand(3..20)
        create_list(:favorite, n2, user: user)
        # 他人がお気に入りした投稿
        n3 = rand(3..20)
        create_list(:favorite, n3, user: another_user)
        # 他人の投稿
        n4 = rand(3..20)
        create_list(:pattern_random, n4)

        # 参照するページの決定
        # 自分の投稿一覧
        @page_select_maker = rand(1..(n1.to_f / amounts_per_page).ceil)
        # お気に入り一覧
        # @page_select_favorite = rand(1..(n2.to_f / amounts_per_page).ceil)
        # puts "ページ指定：#{@page_select}"
      end

      # it 'リクエストが成功' do
      #   get :show, params: {id: user, page: @page_select}
      #   expect(response).to have_http_status 200
      # end

      it 'リクエストが成功かつ適切なレコードを取得' do
        get :show, params: {id: user, page: @page_select_maker}
        expect(response).to have_http_status 200
        expect(assigns :user).to eq user
        expect(assigns :patterns).to eq user.patterns.limit(amounts_per_page).offset(amounts_per_page*(@page_select_maker-1)).reverse_order
        expect(assigns :title).to eq 'ユーザ投稿'
      end

      # ユーザのお気に入り一覧閲覧リンクは実装していない
    end

    context 'PATCH #update' do
      it 'リクエストが失敗' do
        patch :update, params: {id: user, user: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの更新に失敗' do
        expect(user.introduction).to_not eq attributes_data[:introduction]
        patch :update, params: {id: user, user: attributes_data}, as: :js
        user.reload
        expect(user.introduction).to_not eq attributes_data[:introduction]
      end
    end
  end # describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    before do
      sign_in user
    end

    context 'GET #confirm' do
      it '自分のレコードのリクエストが成功' do
        get :confirm, params: {id: user}
        expect(response).to have_http_status 200
      end

      it '他人のレコードのリクエストが失敗' do
        get :confirm, params: {id: another_user}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #edit' do
      it '自分のレコードのリクエストが成功' do
        get :edit, xhr: true,  params: {id: user}, as: :js
        expect(response).to have_http_status 200
      end

      it '他人のレコードのリクエストが失敗' do
        get :edit, xhr: true, params: {id: another_user}, as: :js
        expect(response).to have_http_status 302
      end
    end


    context 'GET #show' do
      # ユーザの投稿一覧データ作成とページ設定
      before do
        # 作成するレコード数
        # 自分の投稿
        n1 = rand(3..20)
        create_list(:pattern_random, n1, user: user)
        # 自分がお気に入りした投稿
        n2 = rand(3..20)
        create_list(:favorite, n2, user: user)
        # 他人がお気に入りした投稿
        n3 = rand(3..20)
        create_list(:favorite, n3, user: another_user)
        # 他人の投稿
        n4 = rand(3..20)
        create_list(:pattern_random, n4)

        # 参照するページの決定
        # 自分の投稿一覧
        @page_select_maker = rand(1..(n1.to_f / amounts_per_page).ceil)
        # お気に入り一覧
        @page_select_favorite = rand(1..(n2.to_f / amounts_per_page).ceil)
        # puts "ページ指定：#{@page_select}"
      end

      context '投稿一覧について' do
        # it 'リクエストが成功' do
        #   get :show, params: {id: user, page: @page_select_maker}
        #   expect(response).to have_http_status 200
        # end

        it 'リクエストが成功かつ適切なレコードを取得' do
          get :show, params: {id: user, page: @page_select_maker}
          expect(response).to have_http_status 200
          expect(assigns :user).to eq user
          expect(assigns :patterns).to eq user.patterns.limit(amounts_per_page).offset(amounts_per_page*(@page_select_maker-1)).reverse_order
          expect(assigns :title).to eq 'ユーザ投稿'
        end
      end

      context 'お気に入り一覧について' do
        # it 'リクエストが成功' do
        #   get :show, params: {id: user, page: @page_select_favorite, favorite: true}
        #   expect(response).to have_http_status 200
        # end

        it 'リクエストが成功かつ適切なレコードを取得' do
          get :show, params: {id: user, page: @page_select_favorite, favorite: true}
          expect(response).to have_http_status 200
          expect(assigns :user).to eq user
          expect(assigns :patterns).to eq user.favorite_patterns.limit(amounts_per_page).offset(amounts_per_page*(@page_select_favorite-1)).reverse_order
          expect(assigns :title).to eq 'お気に入り'
        end
      end
    end # context 'GET #show'

    context 'PATCH #update' do
      it '自分のレコードのリクエストが成功' do
        patch :update, params: {id: user, user: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it '自分のレコードの更新に成功' do
        expect(user.introduction).to_not eq attributes_data[:introduction]
        patch :update, params: {id: user, user: attributes_data}, as: :js
        user.reload
        expect(user.introduction).to eq attributes_data[:introduction]
      end

      it '他人のレコードの更新に失敗' do
        expect(another_user.introduction).to_not eq attributes_data[:introduction]
        patch :update, params: {id: another_user, user: attributes_data}, as: :js
        another_user.reload
        expect(another_user.introduction).to_not eq attributes_data[:introduction]
      end
    end
  end # describe 'ログインユーザの場合'
end # describe MembersController
