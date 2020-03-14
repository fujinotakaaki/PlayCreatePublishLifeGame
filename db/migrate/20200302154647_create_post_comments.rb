class CreatePostComments < ActiveRecord::Migration[5.2]
  # 投稿コメントのモデル
  def change
    create_table :post_comments do |t|
      # 作成ユーザとの関連付け
      t.integer :user_id,     null: false
      # パターンとの関連付け
      t.integer :pattern_id, null: false
      # コメント
      t.string      :body

      t.timestamps
    end
  end
end
