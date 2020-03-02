class CreateCategories < ActiveRecord::Migration[5.2]
  # カテゴリのモデル
  def change
    create_table :categories do |t|
      # カテゴリ名
      t.string :name
      # カテゴリの説明
      t.text    :explanation

      t.timestamps
    end
  end
end
