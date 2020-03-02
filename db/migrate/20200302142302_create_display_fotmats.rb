class CreateDisplayFotmats < ActiveRecord::Migration[5.2]
  # 表示形式のモデル
  def change
    create_table :display_fotmats do |t|
      # 作成ユーザとの関連付け
      t.integer :user_id,             null: false
      # 表示形式名称
      t.string   :name
      # セルの表示形式
      t.string   :alive_and_dead
      # セルの色
      t.integer :font_color,                          default: 0x90EE90 # lightgreen
      # 背景色
      t.integer :background_color,             default: 000            # black

      t.timestamps
    end
  end
end
