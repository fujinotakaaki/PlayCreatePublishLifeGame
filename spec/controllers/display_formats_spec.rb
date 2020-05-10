require 'rails_helper'

RSpec.describe DisplayFormatsController do
  # 自分のアカウント
  let!(:user){create(:user)}
  # 自分の作成したセル表示形式データ
  let!(:my_display_formats){create_list(:display_format, 1+rand(10), user: user)}
  # 他人のセル表示形式データ
  let!(:others_display_formats){create_list(:display_format, 10)}


  describe '非ログインユーザの場合' do
    context 'GET #new' do
      it 'リクエストが失敗' do
        get :new
        expect(response).to have_http_status 302
      end
    end

    context 'GET #edit' do
      it 'リクエストが失敗' do
        get :edit, params: { id: others_display_formats.sample }
        expect(response).to have_http_status 302
      end
    end
  end


  describe 'ログインユーザの場合' do
    before do
      sign_in user
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

      it 'リクエストが失敗（他ユーザのレコードへ）' do
        get :edit, params: { id: others_display_formats.sample }
        expect(response).to have_http_status 302
      end
    end
  end

end
