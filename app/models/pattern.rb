class Pattern < ApplicationRecord
  # パターン名は定義必須
  validates :name, presence: true
  # パターン説明文は定義必須、かつ511文字以内
  validates :introduction, presence: true, length: { maximum: 511 }

  attachment :image

  belongs_to :user
  belongs_to :category
  belongs_to :display_format
  has_many  :pattern_rows,      dependent: :destroy
  has_many  :post_comments, dependent: :destroy
  has_many  :favorites,             dependent: :destroy

  accepts_nested_attributes_for :pattern_rows
end
