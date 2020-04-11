class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # 言語設定関連メソッドのインクルード
  include I18nSetting
  # build_up_pattern_params_fromメソッドをインクルード（ビット列 => dbデータへ変換）
  include MakingsHelper
  # build_up_bit_strings_from, set_to_gonメソッドをインクルード（dbデータ=> ビット列へ変換）
  include PatternsHelper
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  protected

  # ログイン後の遷移先指定
  def after_sign_in_path_for( resource )
    case resource
    when User
      member_path( resource ) # 一般ユーザの場合
    when Admin
      admin_root_path   # 管理者の場合
    end
  end

  # ログアウト後の遷移先
  def after_sign_out_path_for( resource )
    root_path
  end

  # サインアップ時に必要なパラメータの設定
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit( :sign_up, keys: [ :email, :name ] )
  end
end
