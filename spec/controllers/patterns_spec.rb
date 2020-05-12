require 'rails_helper'
# bundle exec rspec spec/controllers/patterns_spec.rb
RSpec.describe PatternsController do
  amounts_per_page = Kaminari.config.default_per_page
  let!(:pattern){create(:pattern_random)}
  let!(:anothers_pattern){create(:pattern_random)}
  let(:patterns){create_list(:pattern_random, rand(4..6))}

  describe '非ログインユーザの場合' do
    context 'get #index' do
      before do
        # 作成するレコード数
        n = rand(3..100)
        # pattern, anothers_patternの個数を考慮
        create_list(:pattern_random, n-2)
        puts "Patternレコード数：#{Pattern.count}, n=#{n}"

        r = n / amounts_per_page
        r += (n % amounts_per_page).zero? ? 0 : 1
        # 参照するページの決定
        @page_select = rand(1..r)
        puts "ページ指定：#{@page_select}"
      end

      it 'リクエストが成功' do
        get :index, params: {page: @page_select}
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :index, params: {page: @page_select}
        expect(assigns :patterns).to eq Pattern.limit(amounts_per_page).offset(amounts_per_page*(@page_select-1)).reverse_order
      end
    end

    context 'post #create' do
      it 'リクエストが失敗' do
        post :create, params: {pattern: pattern.attributes}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが作成されないこと' do
        expect do
          post :create, params: {pattern: pattern.attributes}, as: :js
        end.to_not change(Pattern, :count)
      end
    end

    context 'get #new' do
      it 'リクエストが失敗' do
        get :new
        expect(response).to have_http_status 302
      end
    end

    context 'get #edit' do
      it 'リクエストが失敗' do
        get :edit, params: {id: pattern}
        expect(response).to have_http_status 302
      end
    end

    context 'get #show' do
      it 'リクエストが成功' do
        get :show, params: {id: pattern}
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :show, params: {id: pattern}
        expect(assigns :pattern).to eq pattern
      end
    end

    context 'patch #update' do
      it 'リクエストが失敗' do
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが更新されないこと' do
        expect(pattern.name).to_not eq anothers_pattern.name
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        expect(pattern.reload.name).to_not eq anothers_pattern.name
      end
    end

    context 'delete #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: {id: pattern}
        expect(response).to have_http_status 302
      end

      it 'レコードが減らないこと' do
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

    context 'get #index' do
      before do
        # 作成するレコード数
        n = rand(3..100)
        # pattern, anothers_patternの個数を考慮
        create_list(:pattern_random, n-2)
        puts "Patternレコード数：#{Pattern.count}, n=#{n}"

        r = n / amounts_per_page
        r += (n % amounts_per_page).zero? ? 0 : 1
        # 参照するページの決定
        @page_select = rand(1..r)
        puts "ページ指定：#{@page_select}"
      end

      it 'リクエストが成功' do
        get :index, params: {page: @page_select}
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :index, params: {page: @page_select}
        expect(assigns :patterns).to eq Pattern.limit(amounts_per_page).offset(amounts_per_page*(@page_select-1)).reverse_order
      end
    end

    context 'post #create' do
      it 'リクエストが成功' do
        post :create, params: {pattern: pattern.attributes}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードが登録されること' do
        expect do
          post :create, params: {pattern: pattern.attributes}, as: :js
        end.to change(Pattern, :count).by(1)
        expect((assigns :pattern).id).to_not eq pattern.id
      end
    end

    context 'get #new' do
      it 'リクエストが成功' do
        get :new
        expect(response).to have_http_status 200
      end
    end

    context 'get #edit' do
      it '自分のレコードへはリクエストが成功' do
        get :edit, params: {id: pattern}
        expect(response).to have_http_status 200
      end

      it '他人のレコードへはリクエストが失敗' do
        get :edit, params: {id: anothers_pattern}
        expect(response).to have_http_status 302
      end
    end

    context 'get #show' do
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

    context 'patch #update' do
      it 'リクエストが成功' do
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        expect(response).to have_http_status 200
      end

      it '自分のレコードの更新に成功すること' do
        expect(pattern.name).to_not eq anothers_pattern.name
        patch :update, params: {id: pattern, pattern: anothers_pattern.attributes}, as: :js
        expect(pattern.reload.name).to eq anothers_pattern.name
      end

      it '他人のレコードの更新に失敗すること' do
        expect(anothers_pattern.name).to_not eq pattern.name
        patch :update, params: {id: anothers_pattern, pattern: pattern.attributes}, as: :js
        expect(anothers_pattern.reload.name).to_not eq pattern.name
      end
    end

    context 'delete #destroy' do
      it 'リクエストが成功' do
        delete :destroy, params: {id: pattern}
        expect(response).to redirect_to "/#{I18n.default_locale}/members/#{pattern.user_id}"
      end

      it '自分のレコードの削除に成功すること' do
        expect do
          delete :destroy, params: {id: pattern}
        end.to change(Pattern, :count).by(-1)
      end

      it '他人のレコードの削除に失敗すること' do
        expect do
          delete :destroy, params: {id: anothers_pattern}
        end.to_not change(Pattern, :count)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe PatternsController
