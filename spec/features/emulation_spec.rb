require 'rails_helper'
# bundle exec rspec spec/features/emulation_spec.rb
RSpec.feature 'ライフゲームのエミュレーションテスト', type: :feature, js: true do
  let(:pattern){create(:pattern_random)}
  let(:glider){create(:pattern_glider)}

  scenario '初期状態がページに反映されていること' do
    visit pattern_path(id: pattern)
    # 「第0世代」表示を確認
    current_generation = find(:css, '.patterns__show--lifeGameInfo').text
    expect(current_generation).to eq '第0世代'
    # 初期盤面の表示を確認
    current_diaplay = find(:css, '.patterns__show--lifeGameDisplay').text
    initial_display = build_life_game_text_from(pattern)
    expect(current_diaplay).to eq initial_display
  end

  # グライダーにてライフゲームの挙動をチェック
  scenario '世代更新に成功すること' do
    visit pattern_path(id: glider)
    # １世代更新ボタンの捕捉
    generation_change_button = find(:css, '.patterns__show--lifeGameGenerationChange')
    # セルの表示定義を取得
    cell_conditions = glider.display_format.as_pattern[:cellConditions]
    # １〜３０世代までライフゲームの挙動を確認
    (1..30).each do |generation|
      print "第#{generation}世代"
      # 世代更新実行
      generation_change_button.click
      # 盤面のテキストを取得
      current_diaplay = find(:css, '.patterns__show--lifeGameDisplay').text
      # 処理後の予想されるテキストを構築
      expect_display = bitstrings_to_text(LifeGameMacros::Glider5x5.loop(generation), cell_conditions)
      # 正しく処理されたか判定
      expect(current_diaplay).to eq expect_display
      puts ' => OK'
    end
  end
end # describe 'ライフゲームのエミュレーションテスト'
