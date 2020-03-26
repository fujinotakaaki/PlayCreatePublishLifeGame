module ApplicationHelper
  # アラートが必要なページにのみアラートウィンドウを用意するメソッド
  def include_alert?( fullpath )
    %r{\A/(making|members|patterns/new|users)}.match?( fullpath ) || %r{\A/patterns/\d+/edit\z}.match?( fullpath )
  end

  def display_category_index?( fullpath )
    # users/*とHomes#aboutはカテゴリ表示しない
    ! /\A\/users/.match?( fullpath )
  end

  # Patterns#indexで検索タイトルを取得するメソッド
  def get_index_title( fullpath )
    # 絞り込みキーワード抽出（ $1 = 検索項目, $2 = id ）
    check_item, check_item_id = pickup_genre_and_id( fullpath )
    # タイトルの選定
    if  check_item == 'category' then
      # カテゴリー検索だった場合(match?メソッドなので$1, $2は更新されない)
      %(「#{Category.find( check_item_id ).name}」)
    else
      # 絞り込みなしの場合
      %(全投稿)
    end
  end

  def search_category?( fullpath )
    # 絞り込みキーワード抽出（ $1 = 検索項目, $2 = id ）
    check_item, check_item_id = pickup_genre_and_id( fullpath )
    # カテゴリ検索であったか判定
    check_item&.match?( 'category' )
  end

  def get_category_explanation( fullpath )
    # 絞り込みキーワード抽出（ $1 = 検索項目, $2 = id ）
    category_word, category_id = pickup_genre_and_id( fullpath )
    # カテゴリ説明文を返す
    Category.find( category_id ).explanation
  end

  # URLから検索条件の抽出
  def pickup_genre_and_id( fullpath )
    # マッチング実行 => マッチングしなければnilを返す
    if !! %r{\A/patterns\?(\w+)_id=(\d+)}.match( fullpath ) then
      # 検索条件が見つかれば、「モデル名」とその「id」を返す
      return $1, $2
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
