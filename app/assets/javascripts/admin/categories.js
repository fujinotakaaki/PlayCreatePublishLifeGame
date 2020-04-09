/*
* =============================
* 編集したカテゴリの項目までアニメーション移動するメソッド
* =============================
*/
function moveToEditTag( className ) {
  $('html, body').animate({
    // 移動する座標
    scrollTop: $(`.${className}`).offset().top
  }, 'fast' );
  return false;
}
