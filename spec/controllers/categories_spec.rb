require 'rails_helper'
# bundle exec rspec spec/controllers/categories_spec.rb
RSpec.describe PatternsController do
  # kaminariの１ページあたりのレコード取得数
  let(:amounts_per_page){Kaminari.config.default_per_page}
  let!(:category){create(:category)}
  let!(:patterns){create_list(:pattern, rand(5..10), category: category)}
  let!(:others){create_list(:pattern, rand(5..10))}

  context 'カテゴリ検索' do
    it 'リクエストが成功' do
      get :index, params: { search: { category: category }, page: 1 }
      expect(response).to have_http_status 200
    end

    it '適切なレコードを取得' do
      get :index, params: { search: { category: category } }
      expect(assigns :patterns).to eq category.patterns.limit(amounts_per_page).reverse_order
      expect(assigns :title).to match 'カテゴリ'
    end
  end
end # describe PatternsController
