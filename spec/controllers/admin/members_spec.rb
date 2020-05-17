require 'rails_helper'
# bundle exec rspec spec/controllers/admin/members_spec.rb
RSpec.describe Admin::MembersController do
  let!(:user){create(:user)}
  let!(:my_patterns){create_list(:pattern, rand(5..10), user: user)}
  let!(:patterns){create_list(:pattern, rand(5..10))}
  let(:admin){create(:admin)}

  describe '非ログインユーザの場合' do
    context 'GET #index' do
      before do
        n = User.count
        @per = 10
        # 参照するページの決定
        @page_select = rand(1..(n.to_f / @per).ceil)
        # puts "ページ指定：#{@page_select}"
      end

      it 'リクエストが失敗' do
        get :index, params: {page: @page_select}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it 'リクエストが失敗' do
        get :show, params: {id: user}, as: :csv
        expect(response).to have_http_status 401
      end
    end
  end # describe '非ログインユーザの場合'

  describe '一般ユーザの場合' do
    before do
      sign_in user
    end

    context 'GET #index' do
      before do
        n = User.count
        @per = 10
        # 参照するページの決定
        @page_select = rand(1..(n.to_f / @per).ceil)
        # puts "ページ指定：#{@page_select}"
      end

      it 'リクエストが失敗' do
        get :index, params: {page: @page_select}
        expect(response).to have_http_status 302
      end
    end

    context 'GET #show' do
      it 'リクエストが失敗' do
        get :show, params: {id: user}, as: :csv
        expect(response).to have_http_status 401
      end
    end
  end # describe '一般ユーザの場合'

  describe '管理者の場合' do
    before do
      sign_in admin
    end

    context 'GET #index' do
      before do
        n = User.count
        @per = 10
        # 参照するページの決定
        @page_select = rand(1..(n.to_f / @per).ceil)
        # puts "ページ指定：#{@page_select}"
      end

      # it 'リクエストが成功' do
      #   get :index, params: {page: 1}
      #   expect(response).to have_http_status 200
      # end

      it '適切なレコードを取得' do
        get :index, params: {page: @page_select}
        expect(response).to have_http_status 200
        expect(assigns :users).to eq User.offset(10*(@page_select-1)).limit(@per).reverse_order
      end
    end

    context 'GET #show' do
      it 'リクエストが成功' do
        get :show, params: {id: user}, as: :csv
        expect(response).to have_http_status 200
      end

      it '適切なレコードを取得' do
        get :show, params: {id: user}, as: :csv
        # PICK_UP_KEYS = [ :name, :introduction, :normalized_rows_sequence, :margin_top, :margin_bottom, :margin_left, :margin_right, :is_torus ]
        expect(assigns :patterns).to eq user.patterns.pluck(*Admin::ApplicationController::PICK_UP_KEYS)
      end
    end
  end # describe 'ログインユーザの場合'
end # describe Admin::MembersController
