# class  MakingValidator < ActiveModel::Validator
#   def validate(record)
#     if options[:fields].any?{|field| record.send(field) == "Evil" }
#       record.errors[:base] << "これは悪人だ"
#     end
#   end
# end

class Making < ApplicationRecord
  belongs_to :user
  # validates_with: MakingValidator
end
