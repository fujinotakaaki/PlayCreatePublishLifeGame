module ApplicationHelper
  # アラートが必要なページか判定するメソッド(layouts/application.html.erb)
  def include_alert?( fullpath )
    %r{\A/(making|members|patterns/new|users|display_format)}.match?( fullpath ) || %r{\A/patterns/\d+/edit}.match?( fullpath )
  end

  # アカウント管理関連ページ以外か判定するメソッド(layouts/application.html.erb)
  def include_category_index?( fullpath )
    # users/*とHomes#aboutはカテゴリ表示しない
    ! %r{\A/users}.match?( fullpath )
  end

  # 日付を見やすい書式に変換するメソッド(patterns/property)
  def date_format( create_time )
    # TimeWithZone => DateTimeに変換
    t = create_time.to_datetime
    # 書式に当てはめる（例）2020年03月19日 03:15
    t.strftime('%Y年%m月%d日 %H:%M')
  end
end
