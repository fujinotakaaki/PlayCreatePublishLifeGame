module ApplicationHelper
  def date_format( create_time )
    t = create_time.to_datetime
    sprintf( "%04d年%02d月%02d日 %02d:%02d" , t.year, t.month, t.day, t.hour, t.minute )
  end
end
