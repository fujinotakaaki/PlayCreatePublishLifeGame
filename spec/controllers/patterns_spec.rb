require 'rails_helper'
# bundle exec rspec spec/controllers/patterns_spec.rb
RSpec.describe PatternsController do
  # kaminariの１ページあたりのレコード取得数
  let(:amounts_per_page){Kaminari.config.default_per_page}
  # 自分のレコード
  let!(:pattern){create(:pattern)}
  # 他人のレコード
  let!(:anothers_pattern){create(:pattern)}

  describe '非ログインユーザの場合' do
    context 'GET #index' do
      before do
        # 作成するレコード数
        n = rand(3..100)
        # pattern, anothers_patternの個数を考慮
        create_list(:pattern, n-2)
        # puts "Patternレコード数：#{Pattern.count}, n=#{n}"

        # 参照するページの決定
        @page_select = rand(1..(n.to_f / amounts_per_page).ceil)
        # puts "ページ指定：#{@page_select}"
      end

      context '全投稿の検索' do
        # it 'リクエストが成功' do
        #   get :index, params: {page: @page_select}
        #   expect(response).to have_http_status 200
        # end

        it 'リクエストが成功かつ適切なレコードを取得' do
          get :index, params: {page: @page_select}
          expect(response).to have_http_status 200
          expect(assigns :patterns).to eq Pattern.limit(amounts_per_page).offset(amounts_per_page*(@page_select-1)).reverse_order
          expect(assigns :title).to eq "全投稿"
          expect(assigns :title_detail).to be_nil
        end
      end

      context 'カテゴリ検索'
      context 'キーワード検索'
    end

    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {pattern: pattern.attributes}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの登録に失敗' do
        expect do
          post :create, params: {pattern: pattern.attributes}, as: :js
        end.to_not change(Pattern, :count)
      end
    end

    context 'GET #new' do
      it 'リクエストが失敗' do
        get :new
        expect(response).to have_http_status 302
      end
    end

    context 'GET #edit' do
      it 'リクエストが失敗' do
        get :edit, params: {id: pattern}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it 'リクエストが成功' do
        get :show, params: {id: pattern}
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :show, params: {id: pattern}
        expect(assigns :pattern).to eq pattern
      end
    end

    context 'PATCH #update' do
      it 'リクエストが失敗' do
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの更新に失敗' do
        expect(pattern.name).to_not eq anothers_pattern.name
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        pattern.reload
        expect(pattern.name).to_not eq anothers_pattern.name
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: {id: pattern}
        expect(response).to have_http_status 302
      end

      it 'レコードの削除に失敗' do
        expect do
          delete :destroy, params: {id: pattern}
        end.to_not change(Pattern, :count)
      end
    end
  end# describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    before do
      sign_in pattern.user
      create(:making_random, user: pattern.user)
    end

    context 'GET #index' do
      before do
        # 作成するレコード数
        n = rand(3..100)
        # pattern, anothers_patternの個数を考慮
        create_list(:pattern, n-2)
        # puts "Patternレコード数：#{Pattern.count}, n=#{n}"

        # 参照するページの決定
        @page_select = rand(1..(n.to_f / amounts_per_page).ceil)
        # puts "ページ指定：#{@page_select}"
      end

      context '全投稿の検索' do
        # it 'リクエストが成功' do
        #   get :index, params: {page: @page_select}
        #   expect(response).to have_http_status 200
        # end

        it 'リクエストが成功かつ適切なレコードを取得' do
          get :index, params: {page: @page_select}
          expect(response).to have_http_status 200
          expect(assigns :patterns).to eq Pattern.limit(amounts_per_page).offset(amounts_per_page*(@page_select-1)).reverse_order
          expect(assigns :title).to eq "全投稿"
          expect(assigns :title_detail).to be_nil
        end
      end

      context 'カテゴリ検索'
      context 'キーワード検索'
    end

    context 'POST #create' do
      it 'リクエストが成功' do
        post :create, params: {pattern: anothers_pattern.attributes}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの登録に成功' do
        expect do
          post :create, params: {pattern: anothers_pattern.attributes}, as: :js
        end.to change(Pattern, :count).by(1).and change(Making, :count).by(-1)
      end
    end

    context 'GET #new' do
      it 'リクエストが成功' do
        get :new
        expect(response).to have_http_status 200
      end
    end

    context 'GET #edit' do
      it '自分のレコードのリクエストが成功' do
        get :edit, params: {id: pattern}
        expect(response).to have_http_status 200
      end

      it '他人のレコードのリクエストが失敗' do
        get :edit, params: {id: anothers_pattern}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it 'リクエストが成功' do
        get :show, params: {id: anothers_pattern}
        expect(response).to have_http_status 200
      end

      context 'Ajax通信について' do
        it 'リクエストが成功' do
          get :show, params: {id: anothers_pattern}, as: :json
          expect(response).to have_http_status 200
        end

        it '適切なデータを受信' do
          get :show, params: {id: anothers_pattern}, as: :json
          recieve_json = JSON.parse(response.body)
          expect(recieve_json).to eq anothers_pattern.as_coupler.as_json
        end
      end
    end

    context 'PATCH #update' do
      it 'リクエストが成功' do
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        expect(response).to have_http_status 200
      end

      it '自分のレコードの更新に成功' do
        expect(pattern.name).to_not eq anothers_pattern.name
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        pattern.reload
        expect(pattern.name).to eq anothers_pattern.name
      end

      it '他人のレコードの更新に失敗' do
        expect(anothers_pattern.name).to_not eq pattern.name
        patch :update, params: {id: anothers_pattern, pattern: pattern.attributes}, as: :js
        anothers_pattern.reload
        expect(anothers_pattern.name).to_not eq pattern.name
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが成功' do
        delete :destroy, params: {id: pattern}
        expect(response).to redirect_to "/#{I18n.default_locale}/members/#{pattern.user_id}"
      end

      it '自分のレコードの削除に成功' do
        expect do
          delete :destroy, params: {id: pattern}
        end.to change(Pattern, :count).by(-1)
      end

      it '他人のレコードの削除に失敗' do
        expect do
          delete :destroy, params: {id: anothers_pattern}
        end.to_not change(Pattern, :count)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe PatternsController
