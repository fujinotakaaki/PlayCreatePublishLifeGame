module ApplicationHelper
  # Patterns#indexで検索タイトルを取得するメソッド
  def get_index_title( path )
    # 絞り込みキーワード抽出（ $1 = 検索項目, $2 = id ）
    %r{/patterns\?(\w+)_id=(\d+)}.match( path )
    # タイトルの選定
    if /category/.match?( $1 ) then
      # カテゴリー検索だった場合(match?メソッドなので$1, $2は更新されない)
      %(カテゴリー：「#{Category.find($2).name}」)
    else
      # 絞り込みなしの場合
      %(全投稿)
    end
  end

  # 日付を見やすい書式に変換するメソッド
  def date_format( create_time )
    # TimeWithZone => DateTimeに変換
    t = create_time.to_datetime
    # 書式に当てはめる（例）2020年03月19日 03:15
    sprintf( "%04d年%02d月%02d日 %02d:%02d" , t.year, t.month, t.day, t.hour, t.minute )
  end
end
