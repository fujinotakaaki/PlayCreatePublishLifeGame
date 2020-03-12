class DisplayFotmat < ApplicationRecord
  ERROR_MESSAGES = {
    length: 'セル状態は1文字で定義してください.' ,
    display_format: '「生」と「死」のセル状態は同じ文字にできません.',
    color: 'セルの色と背景色は同じにできません.'
  }

  # 表示形式名は定義する
  validates :name, presence: true

  # セル状態に関するバリデーション
  validates_each :alive, :dead do | record, attr, value |
    # 1文字で無いならNG
    record.errors.add( attr, ERROR_MESSAGES[:length] ) unless value.length == 1
    # 「生」と「死」のセル状態が同じならNG
    record.errors.add( attr, ERROR_MESSAGES[:display_format] ) unless record.alive != record.dead
  end

  # 表示色に関するバリデーション
  validates_each :font_color, :background_color do | record, attr, value |
    # 「生」と「死」のセル状態が同じならNG
    record.errors.add( attr, ERROR_MESSAGES[:color] ) unless record.font_color != record.background_color
  end

  belongs_to :user
  has_many  :patterns
end
