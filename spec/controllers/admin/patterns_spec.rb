require 'rails_helper'
# bundle exec rspec spec/controllers/admin/patterns_spec.rb
RSpec.describe Admin::PatternsController do
  let!(:user){create(:user)}
  let!(:my_patterns){create_list(:pattern, rand(5..10), user: user)}
  let!(:patterns){create_list(:pattern, rand(5..10))}
  let(:admin){create(:admin)}

  describe '非ログインユーザの場合' do
    context 'GET #index' do
      it 'リクエストが失敗' do
        get :index, as: :csv
        expect(response).to have_http_status 401
      end
    end
  end # describe '非ログインユーザの場合'

  describe '一般ユーザの場合' do
    before do
      sign_in user
    end

    context 'GET #index' do
      it 'リクエストが失敗' do
        get :index, as: :csv
        expect(response).to have_http_status 401
      end
    end
  end # describe '一般ユーザの場合'

  describe '管理者の場合' do
    before do
      sign_in admin
    end

    context 'GET #index' do
      it 'リクエストが失敗' do
        get :index, as: :csv
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :index, as: :csv
        expect(assigns :patterns).to eq Pattern.pluck(*Admin::ApplicationController::PICK_UP_KEYS)
      end
    end
  end # describe '管理者の場合'
end # describe Admin::PatternsController
