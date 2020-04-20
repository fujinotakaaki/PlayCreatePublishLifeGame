class AddTransformScaleRateToMakings < ActiveRecord::Migration[5.2]
  def change
    # パターンの縮尺管理用カラム
    add_column :makings, :transform_scale_rate, :integer, default: 100
  end
end
