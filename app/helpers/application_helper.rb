module ApplicationHelper
  # dbのパターン情報をJSのライフゲーム用のデータに変換するメソッド
  def pattern_conversion_to_js( pattern, rows )
    # 最も大きい2進数を取得
    largest_number = rows.max
    # 最も大きい2進数の桁数を算出（但し、0b0なら1桁とする）
    largest_number_bit_length = largest_number.zero? ? 1 : ( Math.log2( largest_number ) + 1 ).to_i
    # 左右の余白を含めたマップ幅を計算
    pattern_bit_length = pattern.margin_left + largest_number_bit_length + pattern.margin_right
    # jsでパターンを扱うための変数作成
    pattern_js = Array.new
    # 上側マージン挿入（不具合予防のため深いコピーで作成）
    pattern_js += Array.new( pattern.margin_top ){ ?0 * pattern_bit_length }
    # パターンを配列に格納していく
    rows.each do | binary_number |
      pattern_js.push( ?0 * pattern.margin_left + ( "%0#{largest_number_bit_length}b" % binary_number ) + ?0 * pattern.margin_right )
    end
    # 下側マージンの挿入（不具合予防のため深いコピーで作成）
    pattern_js += Array.new( pattern.margin_bottom ){ ?0 * pattern_bit_length }
    # js用パターンデータを返す
    return pattern_js
    # 例）"グライダー"の場合
    # ===入力===
    # DBから受け取のデータ
    # pattern = { margin_top: 1, margin_bottom: 1, margin_right: 1, margin_left: 1 }
    # rows = [ 2, 1, 7 ]
    # ===出力===
    # pattern_js = [
    #   "00000",
    #   "00100",
    #   "00010",
    #   "01110",
    #   "00000"
    # ]
  end
end
