require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlayCreatePublishLifeGame
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # 言語設定
    config.i18n.available_locales = [ :ja, :en ]
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :ja
    
    # モデルカラム名の日本語化
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]

    # 時刻設定
    config.active_record.default_timezone = :local
    config.time_zone = 'Tokyo'
    # バリデーションエラーによるfield_with_errorsでwrapされるのを無効にしてくれる
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
