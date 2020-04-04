module Admin::ApplicationHelper
  def simple_date_time
    # TimeWithZone => DateTimeに変換
    t = Time.zone.now.to_datetime
    # 書式に当てはめる（例）202003190315
    t.strftime('%Y%m%d%H%M')
  end
end
