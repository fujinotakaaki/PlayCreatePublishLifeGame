class DisplayFotmat < ApplicationRecord
  belongs_to :user
  has_many  :patterns
end
