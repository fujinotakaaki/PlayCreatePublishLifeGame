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
      t.string     :name,                                       default: '名前なし'
      # パターン紹介文
      t.text        :introduction,                             default: '説明文なし'
      # パターン代表イメージ
      t.string     :image_id
      # 上下左右を循環させるか
      t.boolean :is_torus,                 null: false,  default: false # 非トーラス状
      #上側余白
      t.integer   :margin_top
      #下側余白
      t.integer   :margin_bottom
      #左側余白
      t.integer   :margin_left
      #右側余白
      t.integer   :margin_right
      # 公開・非公開の設定
      t.boolean :is_secret,                null: false, default: false # false => 公開

      t.timestamps
    end
  end
end
