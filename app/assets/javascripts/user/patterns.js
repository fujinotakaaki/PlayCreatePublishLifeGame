/*
* =============================
* 表示形式のリアルタイム適用処理
* =============================
*/
function previewDisplayFormatAtPatternsNew( display_format_id ) {
  // IDからDisplayFormatのデータを取得
  $.ajax({
    url: `/display_formats/${ display_format_id }`,
    type: 'get',
    dataType : 'json'

  }).done( function(data){
    // 成功した場合
    console.log('通信成功');
    //セルの状態表示反映（lifegame/environments.js参照）
    initializeLifeGame( false, false, data );

  }).fail( function(data) {
    // 失敗した場合
    alert('選択された表示形式の取得に失敗しました。');
  });
  return false;
}
