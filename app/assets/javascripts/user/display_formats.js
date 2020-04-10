/*
* =============================
* DisplayFormat#new, #editページにてフォームに入力された表示形式を適用する処理
* =============================
*/
function realTimeReflectDisplayFormat() {
  // 変更に必要な変数の格納
  let changeDisplayFormat = {
    // cssの設定
    cellConditions : {
      alive: $("#display_format_alive").val(),
      dead: $("#display_format_dead").val()
    },
    // セルの表示定義
    cssOptions : {
      fontColor:              $("#display_format_font_color").val(),
      backgroundColor: $("#display_format_background_color").val(),
      fontSize:               $("#display_format_font_size").val(),
      lineHeightRate:    $("#display_format_line_height_rate").val(),
      letterSpacing:       $("#display_format_letter_spacing").val()
    }
  }
  // ライフゲーム画面への変更を反映（lifegame/environments.js参照）
  initializeLifeGame( false, false, changeDisplayFormat )
}
