require 'rails_helper'
# bundle exec rspec spec/controllers/admin/categories_spec.rb
RSpec.describe Admin::CategoriesController do
  let!(:pattern){create(:pattern)}
  let!(:category){create(:category)}
  let(:user){create(:user)}
  let(:admin){create(:admin)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:category)}

  describe '非ログインユーザの場合' do
    context 'GET #index' do
      it 'リクエストが失敗' do
        get :index
        expect(response).to have_http_status 302
      end
    end

    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの登録が失敗' do
        expect do
          post :create, params: {category: attributes_data}, as: :js
        end.to_not change(Category, :count)
      end
    end

    context 'GET #edit' do
      it 'リクエストが失敗' do
        get :edit, xhr: true,  params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'PATCH #update' do
      it 'リクエストが失敗' do
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの更新が失敗' do
        expect(category.name).to_not eq attributes_data[:name]
        patch :update, params: {id: category, category: attributes_data}, as: :js
        category.reload
        expect(category.name).to_not eq attributes_data[:name]
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの削除が失敗' do
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

    context 'GET #index' do
      it 'リクエストが失敗' do
        get :index
        expect(response).to have_http_status 302
      end
    end

    context 'POST #create' do
      it 'リクエストが失敗' do
        post :create, params: {category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの登録が失敗' do
        expect do
          post :create, params: {category: attributes_data}, as: :js
        end.to_not change(Category, :count)
      end
    end

    context 'GET #edit' do
      it 'リクエストが失敗' do
        get :edit, xhr: true,  params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end
    end

    context 'PATCH #update' do
      it 'リクエストが失敗' do
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの更新が失敗' do
        expect(category.name).to_not eq attributes_data[:name]
        patch :update, params: {id: category, category: attributes_data}, as: :js
        category.reload
        expect(category.name).to_not eq attributes_data[:name]
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが失敗' do
        delete :destroy, params: {id: category}, as: :js
        expect(response).to have_http_status 401
      end

      it 'レコードの削除が失敗' do
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

    context 'GET #index' do
      it 'リクエストが成功' do
        get :index
        expect(response).to have_http_status 200
      end
    end

    context 'POST #create' do
      it 'リクエストが成功' do
        post :create, params: {category: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの登録が成功' do
        expect do
          post :create, params: {category: attributes_data}, as: :js
        end.to change(Category, :count).by(1)
      end
    end

    context 'GET #edit' do
      it 'リクエストが成功' do
        get :edit, xhr: true,  params: {id: category}, as: :js
        expect(response).to have_http_status 200
      end
    end

    context 'PATCH #update' do
      it 'リクエストが成功' do
        patch :update, params: {id: category, category: attributes_data}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの更新が成功' do
        expect(category.name).to_not eq attributes_data[:name]
        patch :update, params: {id: category, category: attributes_data}, as: :js
        category.reload
        expect(category.name).to eq attributes_data[:name]
      end
    end

    context 'DELETE #destroy' do
      it 'リクエストが成功' do
        delete :destroy, params: {id: category}, as: :js
        expect(response).to have_http_status 200
      end

      it 'レコードの削除が成功' do
        expect do
          delete :destroy, params: {id: category}, as: :js
        end.to change(Category, :count).by(-1)
      end

      it 'パターンに関連付けされているレコードの削除が失敗' do
        expect do
          delete :destroy, params: {id: pattern.category}, as: :js
        end.to_not change(Category, :count)
      end
    end
  end # describe '管理者の場合'
end # describe Admin::CategoriesController
