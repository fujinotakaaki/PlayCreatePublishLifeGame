require 'rails_helper'
# bundle exec rspec spec/controllers/display_formats_spec.rb
RSpec.describe DisplayFormatsController do
  # 自分のレコード
  let!(:display_format){create(:display_format)}
  # 他人のレコード
  let!(:anothers_display_format){create(:display_format)}

  describe '非ログインユーザの場合' do
    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {display_format: display_format.attributes}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの登録に失敗' do
        expect do
          post :create, params: {display_format: display_format.attributes}, as: :js
        end.to_not change(DisplayFormat, :count)
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
        get :edit, params: {id: display_format}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it 'リクエストが失敗' do
        get :show, params: {id: display_format}, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'PATCH #update' do
      it 'リクエストが失敗' do
        patch :update, params: {id: display_format, display_format: anothers_display_format.attributes}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの更新に失敗' do
        expect(display_format.name).to_not eq anothers_display_format.name
        patch :update, params: {id: display_format, display_format: anothers_display_format.attributes}, as: :js
        display_format.reload
        expect(display_format.name).to_not eq anothers_display_format.name
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: {id: display_format}
        expect(response).to have_http_status 302
      end

      it 'レコードの削除に失敗' do
        expect do
          delete :destroy, params: {id: display_format}
        end.to_not change(DisplayFormat, :count)
      end
    end
  end # describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    before do
      sign_in display_format.user
    end

    context 'POST #create' do
      it 'リクエストが成功' do
        post :create, params: {display_format: anothers_display_format.attributes}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの登録に成功' do
        expect do
          post :create, params: {display_format: anothers_display_format.attributes}, as: :js
        end.to change(DisplayFormat, :count).by(1)
      end
    end

    context 'GET #new' do
      let!(:amounts){rand(2..7)}
      let!(:my_records){create_list(:display_format, amounts, user: display_format.user)}

      it '自分のレコードのリクエストが成功' do
        get :new
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :new
        # 自分の作成したレコードを受け取る
        expect(assigns :display_formats).to eq display_format.user.display_formats
      end
    end

    context 'GET #edit' do
      it '自分のレコードのリクエストが成功' do
        get :edit, params: {id: display_format}
        expect(response).to have_http_status 200
      end

      it '他人のレコードのリクエストが失敗' do
        get :edit, params: {id: anothers_display_format}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it '自分のレコードのリクエストが失敗' do
        get :show, params: {id: display_format}, as: :json
        expect(response).to have_http_status 200
      end

      it '適切なデータを取得' do
        get :show, params: {id: display_format}, as: :json
        recieve_json = JSON.parse(response.body)
        correct_json = display_format.as_pattern.as_json
        expect(recieve_json).to eq correct_json
      end

      it '他人のレコードのリクエストが失敗' do
        get :show, params: {id: anothers_display_format}, as: :json
        expect(response).to have_http_status 302
      end
    end

    context 'PATCH #update' do
      it '自分のレコードのリクエストが成功' do
        patch :update, params: {id: display_format, display_format: anothers_display_format.attributes}, as: :js
        expect(response).to have_http_status 200
      end

      it '自分のレコードの更新に成功' do
        expect(display_format.name).to_not eq anothers_display_format.name
        patch :update, params: {id: display_format, display_format: anothers_display_format.attributes}, as: :js
        display_format.reload
        expect(display_format.name).to eq anothers_display_format.name
      end

      it '他人のレコードの更新に失敗' do
        expect(anothers_display_format.name).to_not eq display_format.name
        patch :update, params: {id: anothers_display_format, display_format: display_format.attributes}, as: :js
        anothers_display_format.reload
        expect(anothers_display_format.name).to_not eq display_format.name
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが成功' do
        delete :destroy, params: { id: display_format }
        expect(response).to redirect_to "/#{I18n.default_locale}/members/#{display_format.user_id}"
      end

      it '自分のレコードの削除に成功' do
        expect do
          delete :destroy, params: {id: display_format}
        end.to change(DisplayFormat, :count).by(-1)
      end

      it '他人のレコードの削除に失敗' do
        expect do
          delete :destroy, params: {id: anothers_display_format}
        end.to_not change(DisplayFormat, :count)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe DisplayFormatsController
