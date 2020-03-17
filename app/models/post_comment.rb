class PostComment < ApplicationRecord
  # コメントは定義必須、かつ200文字以内
  validates :body, presence: true, length: { maximum: 200 }

  belongs_to :user
  belongs_to :pattern
end
