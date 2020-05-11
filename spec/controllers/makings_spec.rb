require 'rails_helper'
# bundle exec rspec spec/controllers/makings_spec.rb
RSpec.describe MakingsController do
  let!(:display_format_first){create(:display_format, id: 1)}
  let!(:display_format_second){create(:display_format, id: 2)}
  # 自分のアカウント
  let(:user){create(:user)}
  # 他人のレコード
  let!(:anothers_making){create(:making_random)}
  # 新規作成データ
  let(:attributes_data){attributes_for(:making_random, :text)}

  describe '非ログインユーザの場合' do
    context 'get #new' do
      it 'リクエストが失敗' do
        get :new
        expect(response).to have_http_status 302
      end
    end

    context 'get #edit' do
      it 'リクエストが失敗' do
        get :edit
        expect(response).to have_http_status 302
      end

      it 'レコードが作成されないこと' do
        expect do
          get :edit
        end.to_not change(Making, :count)
      end
    end

    context 'patch #update' do
      it 'リクエストが失敗' do
        patch :update, params: {making: attributes_data}, as: :js
        expect(response).to have_http_status 401
      end

      # 処理が行われないため、更新するオブジェクトが未定義であることで確認をとる
      it '@makingが定義されていない（レコードが更新されないことの確認の代替）' do
        post :create, params: {making: attributes_data}, as: :js
        expect(assigns :making).to be_nil
      end
    end

    context 'delete #destroy' do
      it 'リクエストが失敗' do
        delete :destroy
        expect(response).to have_http_status 302
      end

      it 'レコードが減らないこと' do
        expect do
          delete :destroy
        end.to_not change(Making, :count)
      end
    end

    context 'post #create' do
      it 'リクエストが失敗' do
        post :create, params: {making: attributes_data}
        expect(response).to have_http_status 302
      end

      # 処理が行われないため、更新するオブジェクトが未定義であることで確認をとる
      it '@makingが定義されていない（レコードが更新されないことの確認の代替）' do
        post :create, params: {making: attributes_data}
        expect(assigns :making).to be_nil
      end
    end
  end # describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    context 'get #new' do
      it 'リクエストが成功' do
        sign_in user
        get :new
        expect(response).to have_http_status 200
      end
    end

    context 'get #edit' do
      context 'レコードを持たないユーザ' do
        before do
          sign_in user
        end

        it 'リクエストが成功' do
          get :edit
          expect(response).to have_http_status 200
        end

        it 'レコードが作成されること' do
          expect do
            get :edit
          end.to change(Making, :count).by(1)
        end
      end

      context 'レコードを持つユーザ' do
        before do
          sign_in anothers_making.user
        end

        it 'リクエストが成功' do
          get :edit
          expect(response).to have_http_status 200
        end

        it '新たなレコードが作成されないこと' do
          expect do
            get :edit
          end.to_not change(Making, :count)
        end

        it '適切なレコードを取得' do
          get :edit
          expect(assigns :making).to eq anothers_making
        end
      end
    end

    context 'patch #update' do
      # レコードを持たないユーザは考慮必要なし

      context 'レコードを持つユーザ' do
        before do
          sign_in anothers_making.user
        end

        it 'リクエストが成功' do
          patch :update, params: {making: attributes_data}, as: :js
          expect(response).to have_http_status 200
        end

        it 'レコードが更新されること' do
          before_normalized_rows_sequence = anothers_making.normalized_rows_sequence
          patch :update, params: {making: attributes_data}, as: :js
          expect(anothers_making.reload.normalized_rows_sequence).to_not eq before_normalized_rows_sequence
        end
      end
    end

    context 'delete #destroy' do
      # レコードを持たないユーザは考慮必要なし

      context 'レコードを持つユーザ' do
        before do
          sign_in anothers_making.user
        end

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
    end

    context 'post #create' do
      # レコードを持たないユーザは考慮必要なし

      context 'レコードを持つユーザ' do
        before do
          sign_in anothers_making.user
        end

        it 'リクエストが成功' do
          post :create, params: {making: attributes_data}
          expect(response).to redirect_to "/#{I18n.default_locale}/making/edit"
        end

        it 'レコードが更新されること' do
          before_normalized_rows_sequence = anothers_making.normalized_rows_sequence
          post :create, params: {making: attributes_data}
          expect(anothers_making.reload.normalized_rows_sequence).to_not eq before_normalized_rows_sequence
        end
      end
    end
  end # describe 'ログインユーザの場合'
end # describe MakingsController
