class Admin::PatternsController < Admin::ApplicationController
  def index
    @patterns = Pattern.all
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "hoge.csv", type: :csv
      end
    end
  end
end
