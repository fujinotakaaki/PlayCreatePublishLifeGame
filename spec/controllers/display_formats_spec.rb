require 'rails_helper'

RSpec.describe DisplayFormatsController do
  # 自分のアカウント
  let!(:user){create(:user)}
  # 自分の作成したセル表示形式データ
  let!(:my_display_formats){create_list(:display_format, 3, user: user)}
  # 他人のセル表示形式データ
  let!(:others_display_formats){create_list(:display_format, 3)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:display_format)}


  describe '非ログインユーザの場合' do
    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {display_format: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが登録されないこと' do
        expect do
          post :create, params: {display_format: attributes_data}, as: :js
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
        get :edit, params: { id: DisplayFormat.take }
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it 'リクエストが失敗' do
        get :show, params: { id: DisplayFormat.take }, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'PATCH #update' do
      it 'リクエストが失敗' do
        sample_record = DisplayFormat.take
        patch :update, params: {id: sample_record, display_format: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが更新されないこと' do
        sample_record = DisplayFormat.take
        expect(sample_record.reload.name).to_not eq attributes_data[:name]
        patch :update, params: {id: sample_record, display_format: attributes_data}, as: :js
        expect(sample_record.reload.name).to_not eq attributes_data[:name]
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: { id: DisplayFormat.take }
        expect(response).to have_http_status 302
      end
    end
  end # describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    before do
      sign_in user
    end

    context 'post #create' do
      it 'リクエストが成功' do
        post :create, params: {display_format: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードが登録できること' do
        expect do
          post :create, params: {display_format: attributes_data}, as: :js
        end.to change(DisplayFormat, :count).by(1)
      end
    end

    context 'GET #new' do
      it 'リクエストが成功' do
        get :new
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :new
        # 自分の作成したレコードを受け取る
        expect(assigns :display_formats).to eq my_display_formats
      end
    end

    context 'GET #edit' do
      it 'リクエストが成功' do
        get :edit, params: { id: my_display_formats.sample }
        expect(response).to have_http_status 200
      end

      it '他ユーザのレコードへのリクエストが失敗' do
        get :edit, params: { id: others_display_formats.sample }
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it 'リクエストが成功' do
        get :show, params: { id: my_display_formats.sample }, as: "application/json"
        expect(response).to have_http_status 200
      end

      it '適切なデータを取得' do
        display_format_sample = my_display_formats.sample
        get :show, params: { id: display_format_sample }, as: "application/json"
        recieve_json = JSON.parse(response.body)
        correct_json = display_format_sample.as_pattern.as_json
        expect(recieve_json).to eq correct_json
      end

      it '他ユーザのレコードへのリクエストが失敗' do
        get :show, params: { id: others_display_formats.sample }, as: "application/json"
        expect(response).to have_http_status 302
      end
    end

    context 'PATCH #update' do
      it 'リクエストが成功' do
        my_sample_record = my_display_formats.sample
        patch :update, params: {id: my_sample_record, display_format: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードが更新されること' do
        my_sample_record = my_display_formats.sample
        expect(my_sample_record.name).to_not eq attributes_data[:name]
        patch :update, params: {id: my_sample_record, display_format: attributes_data}, as: :js
        expect(my_sample_record.reload.name).to eq attributes_data[:name]
      end

      it '他人のレコードは更新できないこと' do
        others_sample_record = others_display_formats.sample
        expect(others_sample_record.name).to_not eq attributes_data[:name]
        patch :update, params: {id: others_sample_record, display_format: attributes_data}, as: :js
        expect(others_sample_record.reload.name).to_not eq attributes_data[:name]
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが成功' do
        my_sample_record = my_display_formats.sample
        delete :destroy, params: { id: my_sample_record }
        expect(response).to redirect_to "/#{I18n.default_locale}/members/#{my_sample_record.user_id}"
      end

      it 'レコードが削除されていること' do
        expect do
          delete :destroy, params: { id: my_display_formats.sample }
        end.to change(DisplayFormat, :count).by(-1)
      end

      it '他人のレコードは削除できないこと' do
        expect do
          delete :destroy, params: { id: others_display_formats.sample }
        end.to_not change(DisplayFormat, :count)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe DisplayFormatsController
