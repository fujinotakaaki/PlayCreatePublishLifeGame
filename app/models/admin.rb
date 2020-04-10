class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # +++++ deviseの設定 ++++++++++++++++++++
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
