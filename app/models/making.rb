class Making < ApplicationRecord
  belongs_to :user
  has_many  :making_rows, dependent: :destroy
end
