# frozen_string_literal: true
Kaminari.configure do |config|
  # 1ページにつき最大15件表示
  config.default_per_page = 15
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  # config.params_on_first_page = false
end