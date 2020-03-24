class DisplayFormat < ApplicationRecord
  DISPLAY_FORMAT_ERROR_MESSAGES = {
    length: 'セル状態は1文字で定義してください.' ,
    display_format: '「生」と「死」のセル状態は同じ文字にできません.',
    color: 'セルの色と背景色は同じにできません.'
  }

  # 表示形式名は定義する
  validates :name, presence: true
  # cssのline-height負の値ではいけない
  validates :line_height_rate, :numericality => { greater_than_or_equal_to: 0 }

  # セル状態に関するバリデーション
  validates_each :alive, :dead do | record, attr, value |
    # 1文字で無いならNG
    record.errors.add( attr, DISPLAY_FORMAT_ERROR_MESSAGES[:length] ) unless value.length == 1
    # 「生」と「死」のセル状態が同じならNG
    record.errors.add( attr, DISPLAY_FORMAT_ERROR_MESSAGES[:display_format] ) unless record.alive != record.dead
  end

  # 表示色に関するバリデーション
  validates_each :font_color, :background_color do | record, attr, value |
    # 「生」と「死」のセル状態が同じならNG
    record.errors.add( attr, DISPLAY_FORMAT_ERROR_MESSAGES[:color] ) unless record.font_color != record.background_color
  end

  belongs_to :user
  has_many  :patterns

  # cssの設定情報を抽出し、json形式に変換するメソッド
  def as_json_css_options
    self.as_json( only: [ :font_color, :background_color, :line_height_rate ] ).transform_keys{ | key | key.to_s.camelize( :lower ).to_sym }
  end

  # セルの表示定義の設定情報を抽出し、json形式に変換するメソッド
  def as_json_cell_conditions( is_torus = false )
    self.as_json( only: [ :alive, :dead ] ).merge( { is_torus: is_torus } ).transform_keys{ | key | key.to_s.camelize( :lower ).to_sym }
  end
end
