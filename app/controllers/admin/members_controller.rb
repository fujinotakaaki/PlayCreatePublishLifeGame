class Admin::MembersController < Admin::ApplicationController
  # ユーザ一覧
  def index
    @users = User.page( params[ :page ] ).includes( :patterns ).reverse_order.per(10)
  end

  # 特定の個人のパターンを情報CSV出力
  def show
    @user = User.find( params[:id] )
    @patterns = @user.patterns.pluck( *Admin::ApplicationController::PICK_UP_KEYS )
    respond_to do | format |
      format.csv do
        send_data render_to_string, filename: "User#{@user.name.camelize}_#{simple_date_time}.csv", type: :csv
      end
    end
  end
end
