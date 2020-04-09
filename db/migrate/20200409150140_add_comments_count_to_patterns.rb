class AddCommentsCountToPatterns < ActiveRecord::Migration[5.2]
  def change
    add_column :patterns, :comments_count, :integer, default: 0
  end
end
