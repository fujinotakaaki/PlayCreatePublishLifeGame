class Favorite < ApplicationRecord
  # ===== アソシエーションの設定 =======================
  belongs_to :user
  belongs_to :pattern, counter_cache: true
  # ================================================
end
