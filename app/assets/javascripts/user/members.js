/*
* =============================
* モーダルウィンドウ操作処理
* =============================
*/
function modalOperation() {
  // モーダルウィンドウを表示・非表示
  $('.members__modal').fadeToggle(function(){
    // 入力フォームをクリア
    $(".members__confirm--textField").val("");
    // ボタン押下不可能に戻す
    checkForm(false);
  });
}


/*
* =============================
* 最終確認フォームの入力監視＆「退会」ボタン有効化処理
* =============================
*/
function checkForm(text) {
  // 確認用文字列の取得
  let machingText = $(".members__confirm--machingText").text();
  // フォームの値と一致するか判定
  let matchingJudge = ( text === machingText );
  // 判定結果をボタンのdisabled属性に反映
  $(".members__confirm--submit").prop( "disabled", ! matchingJudge );
}
