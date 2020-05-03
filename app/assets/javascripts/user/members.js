/*
* =============================
* モーダルウィンドウ表示処理
* =============================
*/
function modalOpen() {
  // モーダルウィンドウを表示
  $('.members__modal').fadeIn();
  // 入力フォームの監視
  $(".members__confirm--textField").keyup( function() {
    let formText = $(this).val();
    let machingText = $(".members__confirm--machingText").text();
    // フォームの値確認
    let judge =( formText == machingText);
    // 一致すれば退会ボタンを使用可能にする
    $(".members__confirm--submit").css({
      'pointer-events': judge && 'auto' || '',
      'background-color': judge && 'red' || ''
    });
  });
}


/*
* =============================
* モーダルウィンドウ非表示処理
* =============================
*/
function modalClose() {
  // モーダルウィンドウ非表示
  $('.members__modal').fadeOut(function(){
    // 入力フォームの初期化処理
    $(".members__confirm--textField").val('').off();
    // 退会ボタンの初期化処理
    $(".members__confirm--submit").css({
      'pointer-events': '',
      'background-color': ''
    });
  });
}
