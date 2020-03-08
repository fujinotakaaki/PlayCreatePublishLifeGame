class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attachment :profile_image
  has_one    :making,              dependent: :destroy
  has_many :patterns
  has_many :display_formats
  has_many :post_comments, dependent: :destroy
  has_many :favorites,             dependent: :destroy
end
