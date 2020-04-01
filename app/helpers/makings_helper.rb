module MakingsHelper
  CONVERT_TEXT_FOR_DB_DATA_ERROR_MESSAGE = {
    length: 'パターンの幅が不揃いです。',
    no_alive_cells: '「生」状態のセルがありません。',
  }

  # concated_bit_stringsから、
  # 上下左右のマージンとパターンの核となる部分について、
  # 各行を16進数に変換した配列を、カンマ区切りの文字列として生成
  def build_up_pattern_params_from( concated_bit_strings )
    # セパレータを基に配列に分割
    rows = concated_bit_strings.split( /[^01]/ )
    # パターンの幅が揃っているか検証
    unless rows.map(&:length).uniq.one? then
      # 列数が一致しないため処理を中断（01とセパレータ以外の文字が含まれる場合もこのエラーとなる）
      return CONVERT_TEXT_FOR_DB_DATA_ERROR_MESSAGE[ :length ]
    end
    # パターンの幅を取得
    pattern_width = rows.first.length
    # ここからは各方向のマージン（空白）を計算
    # 上部
    margin_top = get_top_margin( rows )
    # 下部
    margin_bottom = get_top_margin( rows.reverse )
    # 空白の行数の合算が元々の行数を超えていないか判定
    unless margin_top + margin_bottom < rows.size then
      # 全部の行が0のため処理中断
      return CONVERT_TEXT_FOR_DB_DATA_ERROR_MESSAGE[ :no_alive_cells ]
    end
    # セルが存在する要素について、最初〜最後の位置を表す範囲オブジェクトの作成
    present_alive_cells_range = ( margin_top .. ( -1 - margin_bottom ) )
    # 上下の余白を除去し、各要素を数値化
    each_row_number = rows[ present_alive_cells_range ].map{ | bit_string | bit_string.to_i(2) }
    # 左側マージンの計算（0でない最大値について、パターンの幅から最大値の桁数との差をとる）
    margin_left = pattern_width - each_row_number.max.bit_length
    # 右側マージンの計算（基数を2としたとき、指数が最小値のものを取得）
    margin_right = get_minimum_exponent_base2( each_row_number.select(&:positive?) )
    # 各整数を右側マージンだけ右にビットシフトし、16進数に変換
    normalized_rows_sequence_array = each_row_number.map do | decimal_number |
      decimal_number.zero? ? 0 : ( decimal_number >> margin_right ).to_s(16)
    end
    # Making, Patternモデルに合わせたパラメータの構築
    {
      margin_top: margin_top,
      margin_bottom: margin_bottom,
      margin_left: margin_left,
      margin_right: margin_right,
      normalized_rows_sequence: normalized_rows_sequence_array.join( ?, ),
    }
  end

  # パターンの上側マージンを計算
  def get_top_margin( rows )
    # 取得したパターンの上部のビット列から探索
    rows.each_with_index do | row, idx |
      # 0じゃないビット列が見つかれば終了
      # index番号がmargin_top(bottom)に対応する
      return idx if /[^0]/.match?( row )
    end
    # 全てのビット列が0の場合は配列がそのまま返る、エラー回避のため行数が返るようにする
    rows.size
  end

  # パターンの右側マージンを計算
  def get_minimum_exponent_base2( positive_numbers )
    # 各整数の2を基数とする指数に変換する
    positive_numbers.inject( positive_numbers.first ) do | minimum_exponent, positive_number |
      # 初期値はpositive_numbers.min以上の値であればなんでも良い
      # 奇数が存在すれば強制終了 => 最小の基数は必ず0
      break 0 if positive_number.odd?
      # 指数の数え上げ処理
      current_exponent = 0
      while positive_number.even? do
        # 偶数であれば右へビットシフト
        positive_number >>= 1
        current_exponent += 1
      end
      # 決定した指数を返す
      [ minimum_exponent, current_exponent ].min
    end
  end
end
