class AddDisplayFormatIdToMakings < ActiveRecord::Migration[5.2]
  def change
    add_column :makings, :display_format_id, :integer, null: false	, default: 1
  end
end
