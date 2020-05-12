require 'rails_helper'
# bundle exec rspec spec/controllers/admin/categories_spec.rb
RSpec.describe Admin::CategoriesController do
  let!(:category){create(:category)}
  let(:user){create(:user)}
  let(:admin){create(:admin)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:category)}

  describe '非ログインユーザの場合' do
    context 'get #index' do
      it 'リクエストに失敗' do
        get :index
        expect(response).to have_http_status 302
      end
    end

    context 'post #create' do
      it 'リクエストに失敗' do
        post :create, params: {category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが作成されないこと' do
        expect do
          post :create, params: {category: attributes_data}, as: :js
        end.to_not change(Category, :count)
      end
    end

    context 'get #edit' do
      it 'リクエストに失敗' do
        get :edit, xhr: true,  params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'patch #update' do
      it 'リクエストに失敗' do
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが更新されないこと' do
        expect(category.name).to_not eq attributes_data[:name]
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(category.reload.name).to_not eq attributes_data[:name]
      end
    end

    context 'delete #destroy' do
      it 'リクエストに失敗' do
        delete :destroy, params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが削除されないこと' do
        expect do
          delete :destroy, params: {id: category}, as: :js
        end.to_not change(Category, :count)
      end
    end
  end # describe '非ログインユーザの場合'


  describe '一般ユーザの場合' do
    before do
      sign_in user
    end

    context 'get #index' do
      it 'リクエストに失敗' do
        get :index
        expect(response).to have_http_status 302
      end
    end

    context 'post #create' do
      it 'リクエストに失敗' do
        post :create, params: {category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが作成されないこと' do
        expect do
          post :create, params: {category: attributes_data}, as: :js
        end.to_not change(Category, :count)
      end
    end

    context 'get #edit' do
      it 'リクエストに失敗' do
        get :edit, xhr: true,  params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'patch #update' do
      it 'リクエストに失敗' do
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが更新されないこと' do
        expect(category.name).to_not eq attributes_data[:name]
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(category.reload.name).to_not eq attributes_data[:name]
      end
    end

    context 'delete #destroy' do
      it 'リクエストに失敗' do
        delete :destroy, params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードが削除されないこと' do
        expect do
          delete :destroy, params: {id: category}, as: :js
        end.to_not change(Category, :count)
      end
    end
  end # describe '一般ユーザの場合'

  describe '管理者の場合' do
    before do
      sign_in admin
    end

    context 'get #index' do
      it 'リクエストに成功' do
        get :index
        expect(response).to have_http_status 200
      end
    end

    context 'post #create' do
      it 'リクエストに成功' do
        post :create, params: {category: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの作成に成功' do
        expect do
          post :create, params: {category: attributes_data}, as: :js
        end.to change(Category, :count).by(1)
      end
    end

    context 'get #edit', focus: true do
      it 'リクエストに成功' do
        get :edit, xhr: true,  params: {id: category}, as: :js
        expect(response).to have_http_status 200
      end
    end

    context 'patch #update' do
      it 'リクエストに成功' do
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの更新に成功' do
        expect(category.name).to_not eq attributes_data[:name]
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(category.reload.name).to eq attributes_data[:name]
      end
    end

    context 'delete #destroy' do
      it 'リクエストに成功' do
        delete :destroy, params: {id: category}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの削除に成功' do
        expect do
          delete :destroy, params: {id: category}, as: :js
        end.to change(Category, :count).by(-1)
      end
    end
  end # describe '管理者の場合'
end # describe Admin::CategoriesController
