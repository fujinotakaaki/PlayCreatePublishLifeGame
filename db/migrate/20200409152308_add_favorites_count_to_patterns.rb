class AddFavoritesCountToPatterns < ActiveRecord::Migration[5.2]
  def change
    # お気に入り数管理カラム
    add_column :patterns, :favorites_count, :integer, default: 0
  end
end
