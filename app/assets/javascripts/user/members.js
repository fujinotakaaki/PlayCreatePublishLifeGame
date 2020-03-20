// ユーザ名とイントロダクション編集画面の呼び出しメソッド
function editUserInfo( ele ) {
  // 会員IDの取得
  let id = $(ele).attr('class').match(/members__show--(\d+)$/);
  // 編集可能なユーザか判定(0番以外なら実行)
  if ( ! /0/.test( id[1] ) ) {
    // 編集画面を呼び出す
    $.ajax({
      type : 'GET',
      url : `/members/${id[1]}/edit`,
      dataType: "script"
    })
  }
  return false;
}
