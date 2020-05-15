# rack_testでは#visible?でfalseとなるのは、style="display: none;"またはhidden属性のみ
# つまりCSS（スタイルシート）の設定は無視される
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

    ## その他についてのテスト
    it_puts '検証ボタンが存在' do
      this_button = find(:css, '.makings__edit--verification', visible: false) # 作成中のパターンの有効確認
      expect(this_button.visible?).to be_truthy
    end

    it_puts 'パターンを投稿ボタンが存在かつ非表示' do
      this_button = find(:css, '#patterns__new--jump', visible: false)   # Patterns#newリクエスト
      expect(this_button.visible?).to be_falsey
    end
  end  # it '画面上の要素について', aggregate_failures: true do

  ## パターン作成用インターフェースについてのテスト
  it 'ナビゲーションタグの挙動のテスト' do
    it_puts 'classにactiveを有する要素は唯一であること' do
      within(:css, '.makings__edit--tabNav') do
        active_li = all(:css, '.active')
        expect(active_li.count).to eq 1
      end
    end

    it_puts 'アクティブタグは基本操作タグであること' do
      re = /[^#]++\Z/
      active_li = find(:css, '.makings__edit--tabNav').find(:css, '.active')
      re =~ active_li.find('a')[:href]
      active_div = find_by_id(Regexp.last_match[0])
      expect(active_li.text).to eq '基本操作'
      expect(find(:css, '.tab-content').find('div', class: 'active')).to eq active_div
    end

    it_puts 'アクティブタグの切り替えに成功' do
      re = /[^#]++\Z/
      active_li = find(:css, '.makings__edit--tabNav').find('li', class: 'active')
      re =~ active_li.find('a')[:href]
      initial_active_div_id = Regexp.last_match[0]
      active_div = find_by_id(initial_active_div_id)
      nonactive_li = find(:css, '.makings__edit--tabNav').all('li', class: '!active').sample
      re =~ nonactive_li.find('a')[:href]
      nonactive_div = find_by_id(Regexp.last_match[0], visible: false)
      expect do
        nonactive_li.find('a').click
      end.to change{find(:css, '.makings__edit--tabNav').find('li', class: 'active')}.from(active_li).to(nonactive_li). # 厳密には違うはず（activeがないはずだから）
      and change{find(:css, '.tab-content').find('div', class: 'active')}.from(active_div).to(nonactive_div) # 厳密には違うはず（activeがないはずだから）
      # active_li       = #<Capybara::Node::Element tag="li" path="/HTML/BODY[1]/MAIN[1]/DIV[1]/DIV[1]/DIV[1]/DIV[1]/FORM[1]/H3[1]/UL[1]/LI[1]">
      # nonactive_li = #<Capybara::Node::Element tag="li" path="/HTML/BODY[1]/MAIN[1]/DIV[1]/DIV[1]/DIV[1]/DIV[1]/FORM[1]/H3[1]/UL[1]/LI[4]">
      # オブジェクト番号みたいなので比較するから中身までは厳密に比較しないのだろうか
    end
  end # it 'ナビゲーションタグの挙動のテスト'
end # RSpec.describe "パターン作成ページのテスト"
