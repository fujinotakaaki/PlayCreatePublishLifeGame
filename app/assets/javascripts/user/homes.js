// ===== Topページライフゲーム実行処理 ===============
function topAction() {
  // 「スタート」ボタン除去
  $(".homes__top--start").remove();
  // ライフゲーム実行
  startProcess( 180 );
}
