class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # ニックネームは定義必須
  validates :name,          presence: true
  # 説明文は511文字以内
  validates :introduction, length: { maximum: 511 }

  attachment :profile_image

  has_one    :making,              dependent: :destroy
  has_many :patterns,             dependent: :destroy
  has_many :display_formats
  has_many :post_comments, dependent: :destroy
  has_many :favorites,             dependent: :destroy
end
