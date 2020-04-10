class AddFavoritesCountToPatterns < ActiveRecord::Migration[5.2]
  def change
    add_column :patterns, :favorites_count, :integer, default: 0
  end
end
