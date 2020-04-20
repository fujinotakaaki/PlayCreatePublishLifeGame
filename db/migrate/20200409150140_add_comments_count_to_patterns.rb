class AddCommentsCountToPatterns < ActiveRecord::Migration[5.2]
  def change
    # 関連コメント数管理カラム
    add_column :patterns, :comments_count, :integer, default: 0
  end
end
