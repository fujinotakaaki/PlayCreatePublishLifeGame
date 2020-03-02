class CreatePatternRows < ActiveRecord::Migration[5.2]
  # パターン各行のモデル
  def change
    create_table :pattern_rows do |t|
      # パターンID
      t.integer :pattern_id, null: false
      # ビット列表示のセル
      t.integer :binary_number

      t.timestamps
    end
  end
end
