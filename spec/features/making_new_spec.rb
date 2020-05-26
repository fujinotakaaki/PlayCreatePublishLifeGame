require 'rails_helper'
# bundle exec rspec spec/features/making_new_spec.rb
RSpec.describe "画像からパターンの作成テスト", type: :feature, js: true do
  let(:making){create(:making_random)}
  let!(:display_format){create(:display_format, id: 2)}
  before do
    sign_in making.user
    visit new_making_path
  end
  it '画像以外のアップには失敗' do
    # 手順１：画像のアップロード
    expect(page).to have_content '手順１'
    find_by_id('crop_image', visible: :hidden).attach_file Rails.root.join("spec", "samples", "example.txt")
    expect(page).to have_content '画像データ以外は使用できません'

  end

  it 'パターン作成に成功' do
    # 手順１：画像のアップロード
    expect(page).to have_content '手順１'
    find_by_id('crop_image', visible: :hidden).attach_file Rails.root.join("spec", "samples", "ELUfENbU8AAYVzJ.jpg")
    expect(find_by_id('crop_preview')).to have_css 'img'

    # 手順２：画像のトリミング
    expect(page).to have_content '手順２'
    find(:css, ".makings__new--sectionB").find_button('次へ').click

    # 手順３：画像の２値化
    expect(page).to have_content '手順３'
    within(:css, ".makings__new--sectionC") do
      expect(find_by_id('threshold_form').value).to_not eq 0
      find_button('終了').click
    end

    # データ更新の確認
    making.reload
    expect(making.display_format_id).to eq 2
  end
end # describe '画像からパターンの作成テスト'
