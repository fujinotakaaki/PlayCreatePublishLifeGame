module ApplicationHelper
  # dbのパターン情報をJSのライフゲーム用のデータに変換するメソッド
  def pattern_conversion_to_js( pattern, pattern_rows )
    # 行データがない場合は生きたセル１個の配列とする（なんでもいい）
    # パターンを初めて作る（行データがないため）場合に発生する
    pattern_rows = [ 1 ] if pattern_rows.empty?
    # 最も大きい2進数を取得
    largest_number = pattern_rows.max
    # 最も大きい2進数の桁数を算出（但し、"0b0"なら1桁とする）
    largest_number_bit_length = largest_number.positive? ? 1+ Math.log2( largest_number ).to_i : 1
    # 左右の余白を含めたマップ幅を計算
    pattern_bit_length = pattern.margin_left + largest_number_bit_length + pattern.margin_right
    # jsでパターンを扱うための変数作成
    pattern_js = Array.new
    # 上側マージン挿入（不具合予防のため深いコピーで作成）
    pattern_js += Array.new( pattern.margin_top ){ ?0 * pattern_bit_length }
    # パターンを配列に格納していく
    pattern_rows.each do | binary_number |
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
    # pattern_rows = [ 2, 1, 7 ]
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
