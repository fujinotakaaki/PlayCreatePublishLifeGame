require 'csv'

CSV.generate do |csv|
  csv << Admin::ApplicationController::PICK_UP_KEYS_NAME
  @patterns.each do | pattern |
    csv << pattern
  end
end
