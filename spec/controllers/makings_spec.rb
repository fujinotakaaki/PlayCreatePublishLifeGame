require 'rails_helper'
# bundle exec rspec spec/controllers/makings_spec.rb
RSpec.describe MakingsController do
  # 自分のレコード
  let!(:making){create(:making_random)}
  # 他人のレコード
  let!(:anothers_making){create(:making_random)}
  # 新規ユーザ
  let(:user){create(:user)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:making_random, :text)}
  # レコードのデフォルト設定のために以下２項目は存在が必須
  let!(:display_format_first){create(:display_format, id: 1)}
  let!(:display_format_second){create(:display_format, id: 2)}

  describe '非ログインユーザの場合' do
    context 'GET #new' do
      it 'リクエストが失敗' do
        get :new
        expect(response).to have_http_status 302
      end
    end

    context 'GET #edit' do
      it 'リクエストが失敗' do
        get :edit
        expect(response).to have_http_status 302
      end

      it 'レコードの登録に失敗' do # Making.find_or_create_byのため
        expect do
          get :edit
        end.to_not change(Making, :count)
      end
    end

    context 'PATCH #update' do
      it 'リクエストが失敗' do
        patch :update, params: {making: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      # 処理が行われないため、更新するオブジェクトが未定義であることで確認をとる
      it 'レコードの更新に失敗' do # @makingが定義されていないことで確認
        post :create, params: {making: attributes_data}, as: :js
        expect(assigns :making).to be_nil
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy
        expect(response).to have_http_status 302
      end

      it 'レコードの削除に失敗' do
        expect do
          delete :destroy
        end.to_not change(Making, :count)
      end
    end

    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {making: attributes_data}
        expect(response).to have_http_status 302
      end

      it 'レコードの登録に失敗' do
        expect do
          post :create, params: {making: attributes_data}
        end.to_not change(Making, :count)
      end
    end
  end # describe '非ログインユーザの場合'


  describe 'レコードを持つログインユーザの場合' do
    before do
      sign_in making.user
    end

    context 'GET #new' do
      it 'リクエストが成功' do
        get :new
        expect(response).to have_http_status 200
      end
    end

    context 'GET #edit' do
      it 'リクエストが成功' do
        get :edit
        expect(response).to have_http_status 200
      end

      it '新規レコードの作成に失敗' do
        expect do
          get :edit
        end.to_not change(Making, :count)
      end

      it '適切なレコードを取得' do
        get :edit
        expect(assigns :making).to eq making
      end
    end

    context 'PATCH #update' do
      it 'リクエストが成功' do
        patch :update, params: {making: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードが更新されること' do
        before_normalized_rows_sequence = making.normalized_rows_sequence
        patch :update, params: {making: attributes_data}, as: :js
        making.reload
        expect(before_normalized_rows_sequence).to_not eq making.normalized_rows_sequence
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが成功' do
        delete :destroy
        expect(response).to redirect_to "/#{I18n.default_locale}/making/edit"
      end

      it 'レコードが削除されること' do
        expect do
          delete :destroy
        end.to change(Making, :count).by(-1)
      end
    end

    context 'POST #create' do
      it 'リクエストが成功' do
        post :create, params: {making: attributes_data}
        expect(response).to redirect_to "/#{I18n.default_locale}/making/edit"
      end

      it 'レコードが更新されること' do
        before_normalized_rows_sequence = making.normalized_rows_sequence
        post :create, params: {making: attributes_data}
        making.reload
        expect(before_normalized_rows_sequence).to_not eq making.normalized_rows_sequence
      end
    end
  end # describe 'レコードを持つログインユーザの場合'


  describe 'レコードがないログインユーザの場合' do
    before do
      sign_in user
    end

    context 'GET #edit' do
      it 'リクエストが成功' do
        get :edit
        expect(response).to have_http_status 200
      end

      it '新規レコードの作成に成功' do
        expect do
          get :edit
        end.to change(Making, :count).by(1)
      end

      it '適切なレコードを取得' do
        get :edit
        expect(assigns :making).to eq user.making
      end
    end

    # 通常操作では#editを経由するため、
    # レコードを持つログインユーザと同じテストになるので、
    # その他のアクションのテストは必要なし
    # context 'GET #new'
    # context 'PATCH #update'
    # context 'DELETE #destroy'
    # context 'POST #create'
  end # describe 'レコードがないログインユーザの場合'
end # describe MakingsController
