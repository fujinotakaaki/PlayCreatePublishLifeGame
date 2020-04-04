class DisplayFormat < ApplicationRecord
  DISPLAY_FORMAT_ERROR_MESSAGES = {
    length: "セル表示は1文字で定義してください",
    display_format: "「生」と「死」のセル状態は同じ文字にできません",
    color: "セルの色と背景色は同じにできません",
  }

  # 表示形式名は定義する
  validates :name, presence: true
  # cssのline-height負の値ではいけない（css上は問題ないはず）
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
  has_many :patterns

  # 特定のフォーマットを使用しているパターンがあるか判定
  def used?
    patterns.exists?
  end

  # cssの設定情報をjson形式に変換
  def as_json_css_options
    # css設定に関するカラムの選択
    convert_key_tp_life_game( :font_color, :background_color, :font_size, :line_height_rate, :letter_spacing )
  end

  # セルの表示定義情報をjson形式に変換
  def as_json_cell_conditions
    # セルの表示定義に関するカラムの選択
    convert_key_tp_life_game( :alive, :dead )
  end

  private

  # カラムと値の連想配列作成（キーはJSで取り扱えるように適宜変換）
  def convert_key_tp_life_game( *pick_up_keys )
    as_json( only: pick_up_keys ).transform_keys{ | key | key.camelize( :lower ).to_sym }
  end
end
