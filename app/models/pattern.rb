class Pattern < ApplicationRecord
  # パターン名は定義必須
  validates :name, presence: true
  # パターン説明文は定義必須、かつ511文字以内
  validates :introduction, presence: true, length: { maximum: 511 }

  # refile機能（画像をIDで管理するため）
  attachment :image

  belongs_to :user
  belongs_to :category
  belongs_to :display_format
  has_many  :post_comments, dependent: :destroy
  has_many  :favorites, dependent: :destroy

  # impressionist機能（閲覧数を専用カラムに保存しておく）
  is_impressionable counter_cache: true, column_name: :preview_count

  # お気に入り登録されていればtrueを返す
  def is_favorite_by?( user )
    favorites.where( user_id: user.id ).exists?
  end
end
