class AddPreviewCountToPatterns < ActiveRecord::Migration[5.2]
  def change
    add_column :patterns, :preview_count, :integer, default: 0
  end
end
