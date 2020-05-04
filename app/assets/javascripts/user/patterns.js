/*
* =============================
* 表示形式のリアルタイム適用処理
* =============================
*/
function previewDisplayFormatAtPatternsNew( display_format_id ) {
  //セルの状態表示反映（lifegame/environments.js参照）
  // ajax通信に成功した場合の処理
  const success_callback = data => initializeLifeGame( false, false, data );
  // IDから選択したDisplayFormatのデータを取得できる
  let url = `/display_formats/${ display_format_id }`;
  // ajax通信(user.js)
  ajaxForGet( url, success_callback );
}
