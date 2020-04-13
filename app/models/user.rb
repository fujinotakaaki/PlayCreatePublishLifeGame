class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # +++++ deviseの設定 ++++++++++++++++++++
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # +++++ refileの設定 ++++++++++++++++++++
  attachment :profile_image

  # ===== バリデーションの設定 =========================
  # ニックネームは定義必須
  validates :name, presence: true
  # 説明文は511文字以内
  validates :introduction, length: { maximum: 511 }
  # ================================================

  # ===== アソシエーションの設定 =======================
  has_one    :making, dependent: :destroy
  has_many :patterns, dependent: :destroy
  has_many :display_formats, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  # ================================================

  # アカウント削除の際に入力するワードの生成
  def confirm_text
    "Delete#{name}"
  end
end
