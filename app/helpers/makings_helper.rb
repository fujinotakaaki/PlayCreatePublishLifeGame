require 'prime'

module MakingsHelper
  # making_textから
  # Makingの上下左右のマージン情報に、
  # MakingRowsの数値情報に、
  # 変換する
  def convert_text_to_data( making_text )
    # 改行(\n)を検出してビット列に分割
    rows = making_text.chomp.split # （空白でも分割されるが、現状はこれで）
    # パターンの幅が揃っているか検証
    unless rows.map(&:length).uniq.one? then
      # 不揃いなら処理を中断
      puts 'ERROR1'
      return false, false
    end
    # パターンの幅を取得
    pattern_width = rows.first.length
    # 0と1以外の文字が存在する場合は全て1に変換
    rows.map!{ | row | row.gsub( /[^0]/, ?1 ) }
    # ここからは各方向のマージン（空白）を計算
    making_params = Hash.new
    # 上部
    making_params[ :margin_top ] = get_top_margin( rows )
    # 下部
    making_params[ :margin_bottom ] = get_top_margin( rows.reverse )
    # 空白の行数の合算が元々の行数を超えていないか判定
    unless making_params[ :margin_top ] + making_params[ :margin_bottom ] < rows.size then
      # 全部の行が0のため処理中断（パターンとして不適切）
      puts 'ERROR2'
      return false, false
    end
    # 上下の余白を除去し、配列の各要素を数値化
    remove_vertical_offset_row_numbers = rows[ making_params[ :margin_top ] ... ( rows.size - making_params[ :margin_bottom ] ) ].map{ | row | row.to_i(2) }
    # 0を除く各ビット列のうち、最小値と最大値を取得する。
    min_num, max_num = remove_vertical_offset_row_numbers.filter(&:positive?).minmax
    # 右側マージンの計算（奇数なら0、偶数なら2の指数部を取得）
    making_params[ :margin_right ] = min_num.odd? && 0 || min_num.prime_division.first[1]
    # 左側マージンの計算（パターンの幅から最大値の桁数の差をとる）
    making_params[ :margin_left ] = pattern_width - ( Math.log2( max_num ).to_i + 1 )
    # Makingオブジェクトへ上下左右のマージン情報（Hash）、
    # MakingRowsオブジェクトに渡すための数値の配列（Array）、
    # の２つを返す
    return making_params, remove_vertical_offset_row_numbers.map{ |i| i >> making_params[ :margin_right ] }
  end

  def get_top_margin( rows )
    # 取得したパターンの上部のビット列から探索
    rows.each_with_index do | row, idx |
      # 0じゃないビット列が見つかれば終了
      # index番号がmarginに対応する
      return idx if /[^0]/.match?( row )
    end
    # 全て0のビット列の場合は配列がそのまま返るので、エラー回避のため行数が返るようにする
    rows.size
  end
end
