module PatternsHelper
  # gonにデータを格納するメソッド
  def  set_to_gon( pattern )
    # 表示情報データの呼び出し（MakingモデルであればDefault 1のデータをピックアップ）
    display_format = pattern.try( :display_format ) || DisplayFormat.first
    # gonにデータを格納するメソッド
    gon.push(
      # パターンを１次元配列に変換したものを格納
      pattern: build_up_bit_strings_from( pattern ),
      # cssの設定
      cssOptions: display_format.as_json_css_options,
      # セルの表示定義設定
      cellConditions: display_format.as_json_cell_conditions( pattern.is_torus )
    )
  end

  # dbのパターン情報をJSのライフゲーム用のデータに変換するメソッド
  def build_up_bit_strings_from( pattern )
    # 行データがない場合は生きたセル１個の配列とする（なんでもいい）
    # パターンを初めて作る（行データがないため）場合に発生する
    if pattern.normalized_rows_sequence.nil? then
      return [ 'ようこそ！' ]
    else
      pattern_rows = pattern.normalized_rows_sequence.split( ?, ).map(&:hex)
    end
    # 最も大きい自然数のビット列数を算出
    largest_number_bit_length = pattern_rows.max.bit_length
    # 左右の余白を含めたマップ幅を計算
    pattern_bit_length = pattern.margin_left + largest_number_bit_length + pattern.margin_right
    # jsでパターンを扱うための変数作成
    pattern_js = Array.new
    # 上側マージン挿入（不具合予防のため深いコピーで作成）
    pattern_js += Array.new( pattern.margin_top ){ ?0 * pattern_bit_length }
    # パターン情報を配列に格納
    pattern_rows.each do | decimal_number |
      pattern_js.push(
        ?0 * pattern.margin_left +
        ( "%0#{ largest_number_bit_length }b" % decimal_number ) +
        ?0 * pattern.margin_right
      )
    end
    # 下側マージンの挿入（不具合予防のため深いコピーで作成）
    pattern_js += Array.new( pattern.margin_bottom ){ ?0 * pattern_bit_length }
    # js用パターンデータを返す
    return pattern_js
    # 例）"グライダー"の場合
    # ===入力===
    # DBから受け取ったデータ（実際はHashではない）
    # pattern = {
    #   margin_top: 1,
    #   margin_bottom: 1,
    #   margin_right: 1,
    #   margin_left: 1,
    #   normalized_rows_sequence: "2,1,7"
    # }
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
