class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :pattern, counter_cache: true
end
