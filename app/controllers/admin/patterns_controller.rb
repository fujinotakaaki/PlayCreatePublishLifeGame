class Admin::PatternsController < Admin::ApplicationController

  # 全部のパターン情報を取得
  def index
    @patterns = Pattern.pluck( *Admin::ApplicationController::PICK_UP_KEYS )
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "AllPatternData#{simple_date_time}.csv", type: :csv
      end
    end
  end
end
