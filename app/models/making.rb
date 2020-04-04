class Making < ApplicationRecord
  belongs_to :user

  # MakingレコードからPatternレコードに移す際に必要なパラメータを抽出
  def as_pattern
    # 必要なカラムの列挙
    pick_up_keys = [ :margin_top, :margin_bottom, :margin_left, :margin_right, :is_torus, :normalized_rows_sequence ]
    # データの抽出とキーのシンボル化
    as_json(only: pick_up_keys ).transform_keys(&:to_sym)
  end
end
