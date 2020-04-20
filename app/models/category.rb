class Category < ApplicationRecord
  # ===== バリデーションの設定 =========================
  # 1) カテゴリー名は定義必須
  validates :name, presence: true
  # 2) カテゴリーの説明は定義必須、かつ511文字以内
  validates :explanation, presence: true, length: { maximum: 511 }
  # ================================================

  # ===== アソシエーションの設定 =======================
  has_many :patterns
  # ================================================


  class << self
    # カテゴリ一覧取得
    def get_index
      $categries ||= pluck( :name, :id )
    end
  end
end
