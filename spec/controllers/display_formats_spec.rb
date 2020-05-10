require 'rails_helper'

RSpec.describe DisplayFormatsController do
  # 自分のセル表示形式データ
  let!(:display_format){create(:display_format)}
  let(:my_display_formats){create(:display_format, 1+rand(10), user_id: display_format.user.id)}
  # 他人のセル表示形式データ
  let!(:display_formats){create_list(:display_format, 10)}


  describe '非ログインユーザの場合' do
    context 'GET #new' do
      it 'リクエストが失敗' do
        get :new
        expect(response).to have_http_status 302
      end
    end

    context 'GET #edit' do
      it 'リクエストが失敗' do
        get :edit, params: { id: display_formats.sample }
        expect(response).to have_http_status 302
      end
    end
  end


  describe 'ログインユーザの場合' do
    before do
      sign_in display_format.user
    end

    context 'GET #new' do
      it 'リクエストが成功' do
        get :new
        expect(response).to have_http_status 200
      end
    end

    context 'GET #edit' do
      it 'リクエストが成功' do
        get :edit, params: { id: display_format }
        expect(response).to have_http_status 200
      end

      # gem 'rails-controller-testing'が必要
      # it '適切なレコードを取得' do
      #   get :edit, params: { id: display_format }
      #   expect(assigns :display_formats).to eq my_display_formats
      # end

      it 'リクエストが失敗（他ユーザのレコード）' do
        get :edit, params: { id: display_formats.sample }
        expect(response).to have_http_status 302
      end
    end
  end

end
