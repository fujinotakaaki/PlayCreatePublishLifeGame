class CreateDisplayFormats < ActiveRecord::Migration[5.2]
  # 表示形式のモデル
  def change
    create_table :display_formats do |t|
      # 作成ユーザとの関連付け
      t.integer :user_id,             null: false
      # 表示形式名称
      t.string   :name
      # 生セルの表示形式
      t.string   :alive
      # 死セルの表示形式
      t.string   :dead
      # セルの色(lightgreen)
      t.string :font_color,                             default: '#90EE90'
      # 背景色(black)
      t.string :background_color,                default: '#000'
      # cssの"line-height"の値（単位: %）
      t.string :line_height_rate,                   default: 100

      t.timestamps
    end
  end
end
