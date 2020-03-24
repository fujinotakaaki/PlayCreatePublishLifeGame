class Pattern < ApplicationRecord
  # パターン名は定義必須
  validates :name, presence: true
  # パターン説明文は定義必須、かつ511文字以内
  validates :introduction, presence: true, length: { maximum: 511 }

  attachment :image

  belongs_to :user
  belongs_to :category
  belongs_to :display_format
  has_many  :post_comments, dependent: :destroy
  has_many  :favorites,             dependent: :destroy


  # お気に入り登録されていればtrueを返す
  def favoreted?( user )
    !! Favorite.find_by( user_id: user.id, pattern_id: id )
  end
end
