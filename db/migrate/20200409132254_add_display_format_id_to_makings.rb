class AddDisplayFormatIdToMakings < ActiveRecord::Migration[5.2]
  def change
    # 表示形式設定の管理用
    add_column :makings, :display_format_id, :integer, null: false	, default: 1
  end
end
