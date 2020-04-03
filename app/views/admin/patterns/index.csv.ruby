require 'csv'

CSV.generate do |csv|
  csv << %w( パターン名 説明文 行数列 上 下 左 右 )
  @patterns.each do |m|
    csv_column_values = [
      m.name,
      m.introduction,
      m.normalized_rows_sequence,
      m.margin_top,
      m.margin_bottom,
      m.margin_left,
      m.margin_right
    ]
    csv << csv_column_values
  end
end
