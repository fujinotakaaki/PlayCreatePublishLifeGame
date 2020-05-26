module FeatureMacros
  include Warden::Test::Helpers

  def self.included(base)
    base.before(:each) { Warden.test_mode! }
    base.after(:each) { Warden.test_reset! }
  end

  def sign_in(resource)
    login_as(resource, scope: warden_scope(resource))
  end

  def sign_out(resource)
    logout(warden_scope(resource))
  end

  ## コンソールにexmplesを出力する
  # aggregate_failures: trueのテストでのみ使用を想定
  # テストの内容をコンソールに出力（--format documentationを使用も想定）
  # テストの結果に応じて色も変わるように対応
  # テスト通過とペンディングは集計結果には反映されません
  def it_puts(examples = "")
    indent =  ' ' * 8 # ネストの数？レベル？が分からないので空白の長さは暫定的
    unless block_given? then
      puts "#{indent}\e[33m ┏ #{examples} (PENDING: Not yet implemented)\e[0m"
      return
    end
    puts TrueClass === yield ? "#{indent}\e[34m ┏ #{examples}\e[0m" : "#{indent}\e[31m ┏ #{examples}\e[0m"
  end

  ## Making#edit専用メソッド
  # テキストエリアの入力を比較するメソッド
  def expect_making_textarea(value)
    expect(find_by_id('making_making_text').value).to have_content value
  end

  # エミュレーション画面のテキストを比較するメソッド
  def expect_making_display(value)
    current_display = find(:css, '.patterns__show--lifeGameDisplay')
    expect(current_display.text).to have_content value
  end

  # 基本機能の無地の盤面の作成フォームの値入力処理
  def fill_in_size(height, width)
    fill_in 'blank_pattern_height', with: height
    fill_in 'blank_pattern_width', with: width
  end

  def expect_coupler_preview(value)
    current_display = find(:css, '.makings__edit--couplerPreview')
    expect(current_display.text).to have_content value
  end

  # couplerのキー操作処理
  def window_key_sends(key, **options)
    options_for_js = begin
      options = options&.to_a.map {|pair| "#{pair[0]}: #{pair[1]}"}
      "{ #{options&.join(', ')} }"
    end
    execute_script "keypressHelper('#{key}', #{options_for_js})"
  end

  # 日付を見やすい書式に変換するメソッド(patterns/property)
  def date_format( create_time )
    # TimeWithZone => DateTimeに変換
    t = create_time.to_datetime
    # 書式に当てはめる（例）2020年03月19日 03:15
    t.strftime('%Y年%m月%d日 %H:%M')
  end

  private

  def warden_scope(resource)
    resource.class.name.underscore.to_sym
  end
end
