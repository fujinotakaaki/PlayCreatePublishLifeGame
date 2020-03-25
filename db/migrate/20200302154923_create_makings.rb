class CreateMakings < ActiveRecord::Migration[5.2]
  # パターン作成のモデル
  def change
    create_table :makings do |t|
      # 作成ユーザとの関連付け
      t.integer   :user_id,        null: false
      # 上下左右を循環させるか(非トーラス状)
      t.boolean :is_torus,       null: false, default: false
      #上側余白
      t.integer   :margin_top,                   default: 0
      #下側余白
      t.integer   :margin_bottom,             default: 0
      #左側余白
      t.integer   :margin_left,                   default: 0
      #右側余白
      t.integer   :margin_right,                 default: 0

      t.timestamps
    end
  end
end
