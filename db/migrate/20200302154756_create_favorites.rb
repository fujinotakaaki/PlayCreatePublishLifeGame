class CreateFavorites < ActiveRecord::Migration[5.2]
  # お気に入りのモデル
  def change
    create_table :favorites do |t|
      # 作成ユーザとの関連付け
      t.integer :user_id,     null: false
      # パターンとの関連付け
      t.integer :pattern_id, null: false

      t.timestamps
    end
  end
end
