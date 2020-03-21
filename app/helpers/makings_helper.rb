module MakingsHelper
  CONVERT_TEXT_FOR_DB_DATA_ERROR_MESSAGE = {
    length: 'パターンの幅が不揃いです。',
    no_alive_cells: '「生」状態のセルがありません。'
  }

  # making_textから
  # Makingの上下左右のマージン情報に、
  # MakingRowsの数値情報に、
  # 変換する
  def convert_text_for_db_data( making_text )
    # 改行(\n)を検出してビット列に分割（改行が連続する場合、その間は無視される => 連続した改行はパターンの可視性が向上するから現状は採用）
    rows = making_text.chomp.split # （空白でも分割されるが、現状はこれで）
    # パターンの幅が揃っているか検証
    unless rows.map(&:length).uniq.one? then
      # 列数が一致しないため処理を中断
      return nil, CONVERT_TEXT_FOR_DB_DATA_ERROR_MESSAGE[ :length ]
    end
    # パターンの幅を取得
    pattern_width = rows.first.length
    # 0と1以外の文字が存在する場合は全て1に変換
    rows.map!{ | row | row.gsub( /[^0]/, ?1 ) }
    # ここからは各方向のマージン（空白）を計算
    # 上部
    margin_top = get_top_margin( rows )
    # 下部
    margin_bottom = get_top_margin( rows.reverse )
    # 空白の行数の合算が元々の行数を超えていないか判定
    unless margin_top + margin_bottom < rows.size then
      # 全部の行が0のため処理中断
      return nil, CONVERT_TEXT_FOR_DB_DATA_ERROR_MESSAGE[ :no_alive_cells ]
    end
    # 上下の余白を除去し、各要素を数値化
    remove_vertical_offset_row_numbers = rows[ margin_top ... ( rows.size - margin_bottom ) ].map{ | bit_string | bit_string.to_i(2) }
    # 右側マージンの計算（各行の数値配列から、2の指数部が最小になるものの指数を取得）
    margin_right = get_minimum_place_base2( remove_vertical_offset_row_numbers.select(&:positive?) )
    # 左側マージンの計算（0でない最大値について、パターンの幅から最大値の桁数との差をとる）
    margin_left = pattern_width - remove_vertical_offset_row_numbers.max.bit_length
    # Makingモデルに合わせたデータの構築
    making_params = {
      margin_top: margin_top,
      margin_bottom: margin_bottom,
      margin_left: margin_left,
      margin_right: margin_right
    }
    return making_params, remove_vertical_offset_row_numbers.map{ | bit_string |  bit_string >> margin_right }
    # Makingオブジェクトへ上下左右のマージン情報（Hash）、
    # MakingRowsオブジェクトへ数値の配列（Array）、
    # の２つを返す
  end

  # パターンの上側マージンを計算
  def get_top_margin( rows )
    # 取得したパターンの上部のビット列から探索
    rows.each_with_index do | row, idx |
      # 0じゃないビット列が見つかれば終了
      # index番号がmarginに対応する
      return idx if /[^0]/.match?( row )
    end
    # 全てのビット列が0の場合は配列がそのまま返る、エラー回避のため行数が返るようにする
    rows.size
  end

  # パターンの右側マージンを計算
  def get_minimum_place_base2( numbers )
    # 全ての整数について因数分解した際の2の指数部に変換する
    numbers.map! do | num |
      # 奇数の可能性があるため、初め指数部は0と定義
      exponent = 0
      while( num.even? )
        # 偶数であれば右へビットシフト
        num >>= 1
        exponent += 1
      end
      # 決定した指数を返す
      exponent
    end
    # 指数が最も小さいものを返す
    numbers.min
  end
end
