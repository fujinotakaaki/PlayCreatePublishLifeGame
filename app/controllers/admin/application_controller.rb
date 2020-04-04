class Admin::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_admin!
  layout 'admin/layouts/application'
  # simple_date_timeメソッドのインクルード
  include Admin::ApplicationHelper

  PICK_UP_KEYS_NAME = %w( パターン名 説明文 行数列 上 下 左 右 トーラス面フラグ)
  PICK_UP_KEYS = [ :name, :introduction, :normalized_rows_sequence, :margin_top, :margin_bottom, :margin_left, :margin_right, :is_torus ]
end
