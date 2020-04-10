class PostComment < ApplicationRecord
  # コメントは定義必須、かつ511文字以内
  validates :body, presence: true, length: { maximum: 511 }

  belongs_to :user
  belongs_to :pattern, counter_cache: :comments_count
end
