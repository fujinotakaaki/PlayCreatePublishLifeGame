class Pattern < ApplicationRecord
  attachment :image
  belongs_to :user
  belongs_to :category
  belongs_to :display_format
  has_many  :pattern_rows,      dependent: :destroy
  has_many  :post_comments, dependent: :destroy
  has_many  :favorites,             dependent: :destroy
end
