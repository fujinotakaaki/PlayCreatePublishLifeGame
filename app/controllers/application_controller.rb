class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  # サイトアクセス時のみカテゴリ一覧取得（一般ユーザが編集する機能がないため）
  CATEGORY_INDEX = Category.all.pluck( :id, :name )

  # ログイン成功後の遷移先指定
  def after_sign_in_path_for( resource )
    case resource
    when User
      # 一般ユーザの場合
      member_path( resource )
    when Admin
      # 管理者の場合
      admin_root_path
    end
  end

  # ログアウト後の遷移先
  def after_sign_out_path_for( resource )
    root_path
  end


  protected

  def configure_permitted_parameters
    # サインアップ時に必要なパラメータの設定
    devise_parameter_sanitizer.permit( :sign_up, keys: [ :email, :name ] )
  end
end
