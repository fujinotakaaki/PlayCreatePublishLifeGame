class Category < ApplicationRecord
  # カテゴリー名は定義必須
  validates :name,          presence: true
  # カテゴリーの説明は定義必須、かつ511文字以内
  validates :explanation, presence: true, length: { maximum: 511 }

  has_many :patterns
end
