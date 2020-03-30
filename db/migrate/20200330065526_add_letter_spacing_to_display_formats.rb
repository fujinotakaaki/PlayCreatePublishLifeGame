class AddLetterSpacingToDisplayFormats < ActiveRecord::Migration[5.2]
  def change
    # cssの"letter-spacing"の値（単位: px）
    add_column :display_formats, :letter_spacing, :integer, default: 0
    # cssの"font-size"の値（単位: px）
    add_column :display_formats, :font_size,         :integer, default: 30
  end
end
