class Pattern < ApplicationRecord
  # +++++ refileの設定 ++++++++++++++++++++
  attachment :image

  # ===== バリデーションの設定 =========================
  # パターン名は定義必須
  validates :name, presence: true
  # パターン紹介文は定義必須、かつ511文字以内
  validates :introduction, presence: true, length: { maximum: 511 }
  # ================================================

  # ===== アソシエーションの設定 =======================
  belongs_to :user
  belongs_to :category
  belongs_to :display_format
  has_many  :post_comments, dependent: :destroy
  has_many  :favorites, dependent: :destroy

  # impressionist機能（閲覧数を専用カラムに保存しておく）
  is_impressionable counter_cache: true, column_name: :preview_count
  # ================================================

  # お気に入り登録されていればtrueを返す
  def is_favorite_by?( user )
    favorites.where( user_id: user.id ).exists?
  end

  def as_coupler
    # カンマ区切りの16進数文字列を分割・数値化
    coupler_pattern_rows =  self.normalized_rows_sequence.split( ?, ).map(&:hex)
    # 最も大きい自然数のビット列数を算出
    largest_number_bit_length = coupler_pattern_rows.max.bit_length
    # 各数値をビット列に変換
    coupler_pattern = coupler_pattern_rows.map do | decimal_number |
      "%0#{ largest_number_bit_length }b" % decimal_number
    end
    # カップリングに使用するパターンを返す
    { couplerPattern: coupler_pattern }
  end

  class << self
    # Topページのウェルカムメッセージ
    WELCOM_MESSAGE_PATTERN = {
      display_format_id: nil,
      is_torus: true,
      margin_top: 2,
      margin_bottom: 3,
      margin_left: 4,
      margin_right: 5,
      normalized_rows_sequence: "2a08000050,2a48000250,2aa9990550,2aea25a750,2a8a255400,1469995350,0,0,10300e0000,1120110000,1072200002,1125200105,11272391a7,112411a954,1d230e9553",
    }
    # □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
    # □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
    # □□□□■□■□■□□□□□■□□□□□□□□□□□□□□□□□□□□■□■□□□□□□□□□
    # □□□□■□■□■□□■□□■□□□□□□□□□□□□□□□□□■□□■□■□□□□□□□□□
    # □□□□■□■□■□■□■□■□□■■□□■■□□■□□□□□■□■□■□■□□□□□□□□□
    # □□□□■□■□■□■■■□■□■□□□■□□■□■■□■□□■■■□■□■□□□□□□□□□
    # □□□□■□■□■□■□□□■□■□□□■□□■□■□■□■□■□□□□□□□□□□□□□□□
    # □□□□□■□■□□□■■□■□□■■□□■■□□■□■□■□□■■□■□■□□□□□□□□□
    # □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
    # □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
    # □□□□□■□□□□□□■■□□□□□□□□■■■□□□□□□□□□□□□□□□□□□□□□□
    # □□□□□■□□□■□□■□□□□□□□□■□□□■□□□□□□□□□□□□□□□□□□□□□
    # □□□□□■□□□□□■■■□□■□□□■□□□□□□□□□□□□□□□□□□□■□□□□□□
    # □□□□□■□□□■□□■□□■□■□□■□□□□□□□□□□□□■□□□□□■□■□□□□□
    # □□□□□■□□□■□□■□□■■■□□■□□□■■■□□■□□□■■□■□□■■■□□□□□
    # □□□□□■□□□■□□■□□■□□□□□■□□□■■□■□■□□■□■□■□■□□□□□□□
    # □□□□□■■■□■□□■□□□■■□□□□■■■□■□□■□■□■□■□■□□■■□□□□□
    # □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
    # □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
    # □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□

    # TOPのウェルカムメッセージ用データ
    def welcome
      new( WELCOM_MESSAGE_PATTERN )
    end
  end
end
