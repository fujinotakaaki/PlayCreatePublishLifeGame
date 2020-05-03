/*
* =============================
* ヘッダー直下のアラートを操作するメソッド
* =============================
*/
function callMessageWindow( kind = "", messages = false ) {
  // 表示されている全てのアラートを非表示にする（元々の設定に戻す）
  $(".application__alert--common").css({ "display": "" });
  // メッセージを表示しないのであれば終了
  if ( ! kind ) return;
  // ページトップへ遷移
  movePageTop();
  // 第１引数にアラートの種類が指定されていればその種類のアラートを表示する
  let selectDivAlert = $(`.application__alert--${ kind }`).css({ "display": "block" });
  // さらに、メッセージがあれば置換する
  switch ( toString.call( messages ) ) {
    // 文字列or数値の場合
    case "[object String]": case "[object Number]":
    selectDivAlert.children("ul").html( `<li>${ messages }</li>` );
    break;

    // 配列で渡された場合
    case "[object Array]":
    selectDivAlert.children("ul").html( `<li>${ messages .join( "</li><li>" )}</li>` );
    break;
  }
}


/*
* =============================
* ページトップにアニメーション移動するメソッド
* =============================
*/
function movePageTop() {
  $('html, body').animate({
    // 移動する座標
    scrollTop: 0
  }, 'fast' );
}
