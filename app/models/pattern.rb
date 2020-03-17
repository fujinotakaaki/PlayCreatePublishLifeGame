class Pattern < ApplicationRecord
  # パターン名は定義必須
  validates :name, presence: true
  # パターン説明文は定義必須、かつ200文字以内
  validates :introduction, presence: true, length: { maximum: 200 }

  attachment :image

  belongs_to :user
  belongs_to :category
  belongs_to :display_format
  has_many  :pattern_rows,      dependent: :destroy
  has_many  :post_comments, dependent: :destroy
  has_many  :favorites,             dependent: :destroy
end
