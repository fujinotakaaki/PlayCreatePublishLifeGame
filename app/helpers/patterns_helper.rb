module PatternsHelper
  def get_index_title( path )
    # 絞り込みキーワード抽出
    %r(/patterns\?(\w+)_id=(\d+)).match( path )
    # タイトルの選定
    if /category/.match?($1) then
      # カテゴリー検索だった場合(match?メソッドなので$1, $2は更新されない)
      %(カテゴリー：「#{Category.find($2).name}」)
    else
      # 絞り込みなしの場合
      %(全投稿)
    end
  end
end
