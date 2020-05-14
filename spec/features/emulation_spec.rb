require 'rails_helper'
# bundle exec rspec spec/features/emulation_spec.rb
RSpec.feature 'ライフゲームのエミュレーションテスト', type: :feature, js: true do # Patterns#showにて実行
  let(:pattern){create(:pattern_random)}
  let(:glider){create(:pattern_glider)}

  scenario '初期状態反映に成功' do
    visit pattern_path(id: pattern)
    # 世代カウントを保持する<p>タグを捕捉
    current_generation = find(:css, '.patterns__show--lifeGameInfo')
    # 盤面のテキストを保持する<p>タグを捕捉
    current_diaplay = find(:css, '.patterns__show--lifeGameDisplay')

    # 世代情報の判定
    expect(current_generation.text).to eq '第0世代'
    # 初期盤面のテキストを構築
    initial_display_text = build_life_game_text_from(pattern)
    # 盤面テキストの確認
    expect(current_diaplay.text).to eq initial_display_text
  end

  # グライダーにてライフゲームの挙動をチェック
  scenario '正常な世代更新に成功' do
    visit pattern_path(id: glider)
    # 世代カウントを保持する<p>タグを捕捉
    current_generation = find(:css, '.patterns__show--lifeGameInfo')
    # 盤面のテキストを保持する<p>タグを捕捉
    current_diaplay = find(:css, '.patterns__show--lifeGameDisplay')
    # １世代更新ボタンの捕捉
    generation_change_button = find(:css, '.patterns__show--lifeGameGenerationChange')
    # セルの表示定義を取得
    cell_conditions = glider.display_format.as_pattern[:cellConditions]

    # １〜２１世代までライフゲームの挙動を確認
    (1..21).each do |generation|
      print "第#{generation}世代"
      # 世代更新実行
      generation_change_button.click
      # 処理後の予想されるテキストを構築
      expect_display_text = bitstrings_to_text(LifeGameMacros::Glider5x5.loop(generation), cell_conditions)
      # 正しく処理されることを確認
      expect(current_generation.text).to eq "第#{generation}世代"
      expect(current_diaplay.text).to eq expect_display_text
      puts ' => OK'
    end
  end

  scenario '自動更新の継続に成功' do
    visit pattern_path(id: pattern)
    # 世代カウントを保持する<p>タグを捕捉
    current_generation = find(:css, '.patterns__show--lifeGameInfo')
    # 盤面のテキストを保持する<p>タグを捕捉
    current_diaplay = find(:css, '.patterns__show--lifeGameDisplay')
    # 初期盤面のテキストを構築
    initial_display_text = build_life_game_text_from(pattern)

    # 初期状態の確認
    expect(current_generation.text).to eq '第0世代'
    expect(current_diaplay.text).to eq initial_display_text

    # 開始ボタンを押下
    all(:css, '.patterns__show--lifeGameStart').sample.click
    # ライフゲーム盤面が自動的に世代更新されることを確認
    rand(3..6).times do
      expect do
        sleep 0.5
      end.to change(current_generation, :text).and change(current_diaplay, :text)
    end
  end

  scenario 'リセットに成功すること' do
    visit pattern_path(id: pattern)
    # 世代カウントを保持する<p>タグを捕捉
    current_generation = find(:css, '.patterns__show--lifeGameInfo')
    # 盤面のテキストを保持する<p>タグを捕捉
    current_diaplay = find(:css, '.patterns__show--lifeGameDisplay')
    # １世代更新ボタンの捕捉
    generation_change_button = find(:css, '.patterns__show--lifeGameGenerationChange')

    # ライフゲーム盤面が世代更新されることを確認
    expect do
      # １世代更新ボタンを押下
      generation_change_button.click
    end.to change(current_generation, :text).from('第0世代').to('第1世代')
    .and change(current_diaplay, :text).from(build_life_game_text_from pattern)

    # ライフゲーム盤面がrリセットされる（元に戻る）ことを確認
    expect do
      # リセットボタンを押下
      find(:css, '.patterns__show--lifeGameRefresh').click
    end.to change(current_generation, :text).from('第1世代').to('第0世代')
    .and change(current_diaplay, :text).to(build_life_game_text_from pattern)
  end
end # describe 'ライフゲームのエミュレーションテスト'
