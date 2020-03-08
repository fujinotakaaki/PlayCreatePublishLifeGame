class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  attachment :profile_image
  has_one    :making,              dependent: :destroy#, class_name: Making
  has_many :patterns,             dependent: :destroy
  has_many :display_formats
  has_many :post_comments, dependent: :destroy
  has_many :favorites,             dependent: :destroy
end
