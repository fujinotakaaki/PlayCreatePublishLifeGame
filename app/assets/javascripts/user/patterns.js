/*
* =============================
* 画像アップロード時のサムネイルを表示処理
* =============================
*/
function displayUploadPatternImage() {
  // ファイル情報取得
  let upLoadFile = $(this).prop("files")[0];
  // 投稿済みの画像があった場合は除く
  $(".patterns__new--img").remove();
  // 画像でない場合はそのファイルを削除・強制終了
  if ( ! upLoadFile.type.match("image.*") ) {
    $(this).val(""); // クリア
    callMessageWindow( 'danger', '画像以外のファイルは投稿できません。' )
    return false;
  }
  let reader = new FileReader();
  reader.onload = function() {
    // imgタグに必要な情報を追加
    var img_src = $("<img>").attr( "src", reader.result ).attr( "class", "patterns__new--img" );
    // imgタグの挿入
    $("#pattern_image").after( img_src );
  }
  // 画像表示
  reader.readAsDataURL( upLoadFile );
}


/*
* =============================
* 表示形式のリアルタイム適用処理
* =============================
*/
function previewDisplayFormatAtPatternsNew() {
  // 選択されたDisplayFormatのIDを取得
  let display_format_id = $(this).val();

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
    console.log('通信失敗');
  });
  return false;
}