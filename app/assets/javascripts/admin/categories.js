/*
* =============================
* 編集したカテゴリの項目までアニメーション移動するメソッド
* =============================
*/
function moveToEditTag( categoryId ) {
  $('html, body').animate({
    // 移動する座標
    scrollTop: $(`.categories___article--categoryId\\=${categoryId}`).offset().top
  }, 'fast' );
}
