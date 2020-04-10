module Admin::Concerns::I18nSetting
  protected
  # 言語設定
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    { :locale => I18n.locale }.merge options
  end
end
