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
  try {
    // アクション名が定義されていなければ強制終了
    if ( ! gon.action ) throw new UserException('InvalidGon');
  } catch(e) {
    // console.error(e.message);
    return;
  }

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
  // ライフゲームの表示初期化（lifegame/environment.js参照）
  initializeLifeGame();
  // アクション名リセット（ページ遷移後のにも値が引き継がれるためリセットする）
  gon.action = "";
});


/*
* =============================
* ドロップダウンメニューの表示切り替え
* =============================
*/
function showDropdownMenue(self) {
  // ドロップダウンメニューの本体の捕捉
  let target = $(".application__header--dropdownMenue");
  // 閉じるボタンの操作
  if ( ! self ) {
    // ドロップダウンメニューを非表示
    target.hide();
    return false;
  }
  // ドロップダウンメニューの基準位置となる要素の情報取得
  let selfOffset = $(self).offset();
  let selfWidth = $(self).width();
  // ドロップダウンメニューの表示
  target.css({
    left: selfOffset.left + selfWidth - target.width()
  }).show();
}


/*
* =============================
* 画像アップロード時のサムネイル表示処理
* =============================
*/
function displayUploadImage( self ) {
  // 画像の読み込みが完了した際の処理
  const finishOnLoad = function( element, srcData ) {
    // imgタグに必要な情報を追加
    let imgSrc = $("<img>").attr({
      "src": srcData,
      "class": "application__common--imgPreview"
    });
    // 投稿済みの画像があった場合は除く
    $(".application__common--imgPreview").remove();
    // 画像の挿入
    $(element).parent().before( imgSrc );
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
  // 画像でない場合はそのファイルを削除・強制終了
  if ( ! upLoadFile.type.includes('image') ) {
    // アップロードファイルを削除
    $(element).val("");
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


/*
* =============================
* ajax通信（getメソッドのみ対応）
* =============================
*/
const ajaxForGet = function( url, successCallback, failCallback = () => console.error("通信に失敗しました") ) {
  $.ajax({
    url: url,
    type: 'get',
    dataType : 'json'
  }).done( data =>
    successCallback(data)
  ).fail( () =>
  failCallback()
);
}
