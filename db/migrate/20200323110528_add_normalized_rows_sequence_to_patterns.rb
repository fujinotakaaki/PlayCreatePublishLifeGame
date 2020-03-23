class AddNormalizedRowsSequenceToPatterns < ActiveRecord::Migration[5.2]
  def change
    # パターンの余白を除去し、行先頭から正規化した数列
    add_column :patterns, :normalized_rows_sequence, :text
  end
end
