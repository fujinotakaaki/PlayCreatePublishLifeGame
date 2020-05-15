# rack-testでは#visible?でfalseとなるのは、style="display: none;"またはhidden属性のみにしか
# https://stackoverflow.com/questions/40825218/checking-for-visibility-with-capybara
require 'rails_helper'
# bundle exec rspec spec/features/making_spec.rb
RSpec.describe "パターン作成ページのテスト", type: :feature, js: true do # Making#editページ
  let(:making){create(:making_blank)}
  # let(:making){create(:making_random)}
  before do
    sign_in making.user
    visit edit_making_path
  end

  it '画面上の要素について', aggregate_failures: true do
    ## フォームに関するテスト
    it_puts 'トーラス面設定用のラジオボタンが存在' do
      expect(page.has_css?('#making_is_torus_true') && page.has_css?('#making_is_torus_false')).to be_truthy
    end

    it_puts 'パターン編集フォームに説明文が存在' do
      this_field = find(:css, '.makings__edit--textarea')
      expect(this_field.text).to include 'パターン作成の説明'
    end

    it_puts 'セルの縮尺設定用のスケールバーが存在' do
      expect(page).to have_css '#making_transform_scale_rate'
    end

    it_puts '変更を保存ボタンが存在かつ非表示' do
      this_button = find(:css, '#makings__edit--update', visible: false) # Makings#updateリクエスト
      expect(this_button.visible?).to be_falsey
    end

    ## その他の状態についてのテスト
    it_puts '検証ボタンが存在' do
      this_button = find(:css, '.makings__edit--verification', visible: false) # 作成中のパターンの有効確認
      expect(this_button.visible?).to be_truthy
    end

    it_puts 'パターンを投稿ボタンが存在かつ非表示' do
      this_button = find(:css, '#patterns__new--jump', visible: false)   # Patterns#newリクエスト
      expect(this_button.visible?).to be_falsey
    end
  end # it '画面上の要素について', aggregate_failures: true do
end # RSpec.describe "パターン作成ページのテスト"
