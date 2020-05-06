class DisplayFormat < ApplicationRecord
  # ===== バリデーションの設定 =========================
  # 1) 表示形式名（入力必須）
  validates :name, presence: true

  # 2) line-heightの値（負の値ではいけない）
  validates :line_height_rate, :numericality => { greater_than_or_equal_to: 0, message: "0未満は無効です。" }

  # 3) セル状態
  # 3-1) 「生」のセルは「0」の使用を許可しない
  validates :alive, format: { with: /[^0]/, message: "は「0」を使用できません。" }

  # 3-2) 「生」のセル状態は「死」と被らないこと
  validates_each :alive do | record, attr, value |
    # 1文字でないならNG
    record.errors.add( attr, "は1文字で定義してください" ) unless value.length == 1
    # 「生」と「死」のセル状態が同じならNG
    record.errors.add( attr, "は「死」セルと同じ文字を使用できません" ) unless record.alive != record.dead
  end

  # 3-3) 「死」のセル状態は「生」と被らないこと
  validates_each :dead do | record, attr, value |
    # 1文字でないならNG
    record.errors.add( attr, "は1文字で定義してください" ) unless value.length == 1
    # 「生」と「死」のセル状態が同じならNG
    record.errors.add( attr, "は「生」セルと同じ文字を使用できません" ) unless record.alive != record.dead
  end


  # 4) 表示色
  # 4-1) セルの色（文字の色）
  validates_each :font_color do | record, attr, value |
    record.errors.add( attr, "は背景色と同じにできません" ) unless record.font_color != record.background_color
  end

  # 4-2) 背景色
  validates_each :background_color do | record, attr, value |
    record.errors.add( attr, "はセルの色と同じにできません" ) unless record.font_color != record.background_color
  end

  # 5) セルの横間隔（presence: trueも補える）
  validates :letter_spacing, numericality: true

  # 6) フォントサイズ（presence: trueも補える）
  validates :font_size, :numericality => { greater_than_or_equal_to: 0, message: "0未満は無効です。" }
  # ================================================

  # ===== アソシエーションの設定 =======================
  belongs_to :user
  has_many :patterns
  has_many :makings
  # ================================================

  # 特定のフォーマットを使用しているパターンがあるか判定
  def used?
    patterns.exists?
  end

  # 所定のjson用データに変換
  def as_pattern
    {
      # cssの設定
      cssOptions:   as_json_css_options,
      # セルの表示定義設定
      cellConditions: as_json_cell_conditions,
    }
  end


  class << self
    WELCOM_MESSAGE_DISPLAY_FORMAT = {
      alive: '■',
      dead: '□',
      font_size: 40,
      line_height_rate: 53,
      letter_spacing: -3,
    }

    # TOPのウェルカムメッセージ用データ
    def welcome
      new( WELCOM_MESSAGE_DISPLAY_FORMAT )
    end

    # 表示形式一覧取得
    def list
      pluck( :name, :id ).to_h
    end
  end

  private

  # cssの設定情報をjson形式に変換
  def as_json_css_options
    # css設定に関するカラムの選択
    as_json_with_translate_case_style( :font_color, :background_color, :font_size, :line_height_rate, :letter_spacing )
  end

  # セルの表示定義情報をjson形式に変換
  def as_json_cell_conditions
    # セルの表示定義に関するカラムの選択
    as_json_with_translate_case_style( :alive, :dead )
  end

  # カラムと値の連想配列作成（キーはJSで取り扱えるように適宜変換）
  def as_json_with_translate_case_style( *pick_up_keys )
    as_json( only: pick_up_keys ).transform_keys{ | key | key.camelize( :lower ).to_sym }
  end
end
