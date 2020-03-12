class Category < ApplicationRecord
  # カテゴリー名は定義必須
  validates :name,          presence: true
  # カテゴリーの説明は定義必須、かつ200文字以内
  validates :explanation, presence: true, length: { maximum: 200 }

  has_many :patterns
end
