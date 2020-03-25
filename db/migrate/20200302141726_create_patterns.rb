class CreatePatterns < ActiveRecord::Migration[5.2]
  # パターンのモデル
  def change
    create_table :patterns do |t|
      # 作成ユーザとの関連付け
      t.integer   :user_id,                  null: false
      # カテゴリとの関連付け
      t.integer   :category_id,           null: false	, default: 1
      # 表示形式との関連付け
      t.integer   :display_format_id, null: false	, default: 1
      # パターン名
      t.string     :name
      # パターン紹介文
      t.text        :introduction
      # パターン代表イメージ
      t.string     :image_id
      # 上下左右を循環させるか(非トーラス面)
      t.boolean :is_torus,                 null: false,  default: false
      #上側余白
      t.integer   :margin_top
      #下側余白
      t.integer   :margin_bottom
      #左側余白
      t.integer   :margin_left
      #右側余白
      t.integer   :margin_right
      # 公開・非公開の設定(false => 公開)
      t.boolean :is_secret,                null: false, default: false

      t.timestamps
    end
  end
end
