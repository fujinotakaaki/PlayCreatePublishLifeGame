/*
* =============================
* 画像アップロード時のサムネイルを表示処理
* =============================
*/
function displayUploadImage( self ) {
  upLoadFile = $(self).prop('files')[0];
  // 画像でない場合はそのファイルを削除・強制終了
  if ( ! upLoadFile.type.match("image.*") ) {
    $(self).val(""); // クリア
    callMessageWindow( 'danger', '画像以外のファイルは投稿できません。' )
    return false;
  }
  let reader = new FileReader();
  reader.onload = function() {
    // imgタグに必要な情報を追加
    var img_src = $("<img>").attr( "src", reader.result ).attr( "class", "application__common--imgPreview" );
    // 投稿済みの画像があった場合は除く
    $(".application__common--imgPreview").remove();
    // 画像の挿入
    $(self).parent().before( img_src );
  }
  // 画像表示
  reader.readAsDataURL( upLoadFile );
}


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
