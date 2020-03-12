class CreateMakingRows < ActiveRecord::Migration[5.2]
  def change
    create_table :making_rows do |t|
      # 製作パターンとの関連付け
      t.integer :making_id,          null: false
      # ビット列表示のセル
      t.integer :binary_number

      t.timestamps
    end
  end
end
