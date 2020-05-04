// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require cropper.min.js
//= require turbolinks
//= require jquery
//= require bootstrap-sprockets
//= require_tree ./common
//= require_tree ./lifegame
//= require_tree ./user


/*
* =============================
* ライフゲームエミュレータ画面整形処理
* =============================
*/
$(document).on('turbolinks:load', function() {
  // アクション名が定義されていなければ強制終了
  if ( ! gon.action ) return;
  // トップページの場合の処理
  if ( gon.action == "top" ) {
    // 背景色を変更
    $("body").css({
      'background-color': 'black',
      'color': 'black'
    });
    // ライフゲーム操作用のインターフェース削除
    $(".patterns__show--lifeGameInterface").remove();
  }
  // カテゴリ欄の削除
  $(".application__layouts--leftSection").remove();
  // パターン表示を画面最大に
  $(".application__layouts--rightSection").removeClass().addClass("col-lg-12");
  // ライフゲームの表示初期化（lifegame/environment.js参照）
  initializeLifeGame();
  // アクション名リセット（ページ遷移後のにも値が引き継がれるためリセットする）
  gon.action = "";
});


/*
* =============================
* 画像アップロード時のサムネイル表示処理
* =============================
*/
function displayUploadImage( self ) {
  // 画像の読み込みが完了した際の処理
  const finishOnLoad = function( element, src_data ) {
    // imgタグに必要な情報を追加
    let img_src = $("<img>").attr({
      "src": src_data,
      "class": "application__common--imgPreview"
    });
    // 投稿済みの画像があった場合は除く
    $(".application__common--imgPreview").remove();
    // 画像の挿入
    $(element).parent().before( img_src );
  }
  // アップロードファイルのバリデーション実行
  validateImageFile( self, finishOnLoad );
}


/*
* =============================
* アップロードファイルのバリデーション処理（画像のみ許可）
* =============================
*/
const validateImageFile = function( element, finishOnLoad ) {
  let upLoadFile = $(element).prop('files')[0];
  let regexp = /image/;
  // 画像でない場合はそのファイルを削除・強制終了
  if ( ! regexp.test( upLoadFile.type ) ) {
    $(element).val(""); // クリア
    callMessageWindow( 'danger', '画像データ以外は使用できません。' );
    // バリデーション結果を返す
    return false;
  }
  let reader = new FileReader();
  reader.onload = () => finishOnLoad( element, reader.result );
  // 画像読み込み
  reader.readAsDataURL( upLoadFile );
  // バリデーション結果を返す
  return true;
}
