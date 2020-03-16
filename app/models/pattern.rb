class Pattern < ApplicationRecord
  # パターン名は定義必須
  validates :name, presence: true
  # パターン説明文は定義必須、かつ200文字以内
  validates :introduction, presence: true, length: { maximum: 200 }

  attachment :image

  belongs_to :user, :counter_cache => true
  belongs_to :category, :counter_cache => true
  belongs_to :display_format, :counter_cache => true
  has_many  :pattern_rows,      dependent: :destroy
  has_many  :post_comments, dependent: :destroy
  has_many  :favorites,             dependent: :destroy
end
