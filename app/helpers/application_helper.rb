module ApplicationHelper
  # アラートが必要なページか判定するメソッド(layouts/application.html.erb)
  def include_alert?( fullpath )
    # データの作成や更新に関わるページにのみインポートする
    %r{/(making|members|patterns/new|users|display_format)}.match?( fullpath ) ||
    %r{/patterns/\d+/edit}.match?( fullpath )
  end

  # カテゴリ一覧の表示判定メソッド(layouts/application.html.erb)
  def include_category_index?( fullpath, controller_name )
    # homes, makings, アカウント管理関連コントローラではカテゴリ一覧を表示しない
    ! ( %r{/(users|confirm)}.match?( fullpath ) ||  %w[ homes makings ].include?( controller_name ) )
  end

  # 日付を見やすい書式に変換するメソッド(patterns/property)
  def date_format( create_time )
    # TimeWithZone => DateTimeに変換
    t = create_time.to_datetime
    # 書式に当てはめる（例）2020年03月19日 03:15
    t.strftime('%Y年%m月%d日 %H:%M')
  end
end
