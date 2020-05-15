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

  # aggregate_failures: trueのテストでのみ使用を想定
  # テストの内容をコンソールに出力（--format documentationを使用も想定）
  # テストの結果に応じて色も変わるように対応
  # テスト通過とペンディングは集計結果には反映されません
  def it_puts(examples = "")
    print ' ' * 3 # ネストの数が分からないので暫定的なインデントの数を3とする
    unless block_given? then
      puts "\e[33m ┏ #{examples} (PENDING: Not yet implemented)\e[0m"
      return
    end
    puts TrueClass === yield ? "\e[34m ┏ #{examples}\e[0m" : "\e[31m ┏ #{examples}\e[0m"
  end

  private

  def warden_scope(resource)
    resource.class.name.underscore.to_sym
  end
end
