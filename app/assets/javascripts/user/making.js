// Makings#editのパターン入力フォームでの動作
$(document).on('keypress', '#making_text', function(e){
  // 押下したキーの種類で処理分岐
  switch ( e.which ) {

    // "Enter"キー
    case 13:
    // 行数を計算
    let row_count = $(this).val().split("\n").length;
    // 作成中のパターンが全部露出するようにテキストエリアの高さを調整する
    $(this).css({ 'height': `${ 5 +( row_count + 1) * 20 }px` });
    break;

    // 0 or 1キー
    case 48:
    case 49:
    // 入力を許可（ただし、パターンのエミュレートを禁止する）
    break;

    // その他
    default:
    // 入力を阻害
    return false;
  }
});
// 編集が行われた場合に画面表示を切り替える処理
$(document).on('keyup', '#making_text', function(){
  // エミュレーション用画面切替と作成中パターンの反映
   removeInterfaceAndDisplayMakingPattern(this);
});

// ボタン除去とプレビュー表示への切替
function removeInterfaceAndDisplayMakingPattern() {
  // 編集中のビット列を表示形式に変換する
  let convertDisplayText = $("#making_text").val().split("\n").map( bitString => bitString.replace( /[^01]/g, "" ).replace( /0/g, "□" ).replace( /1/g, "■" ) ).join("<br>")
  // 編集内容に合わせてリアルタイムにパターンへ反映させる
  $(".patterns__show--lifeGameDisplay").html( convertDisplayText ).css({'text-align': 'left'});
  // 世代情報を「プレビューを表示中」に切替え
  $(".patterns__show--lifeGameInfo").text( "プレビューを表示中" );
  // 操作ボタンの削除（編集中のパターンはエミュレートできないため）
  $(".patterns__show--lifeGameInterface").text('');
  // 「変更を保存」ボタンを表示する
  $(".makings__edit--submit").css({ "display": "" });
}


function autoComplement( side ) {
  // 右側に補完するか判定（falseなら左側に補完）
  let autoCompleteToRightSide = /right/i.test( side );
  // テキストエリアのテキストを行区切りで配列化
  let makingPatternArray = $("#making_text").val().split("\n")
  // 最長の文字列の文字数を取得
  let maxBitLength = makingPatternArray.reduce( ( max, currentBitString ) => ( max < currentBitString.length ? currentBitString.length : max ), 0 );
  // 横方向に対するビットの補完処理（0で補完）
  let autoComplementMakingPatternArray = makingPatternArray.map( function ( currentBitString ) {
    if ( autoCompleteToRightSide ) {
      // 右側に補完する場合の処理
      return currentBitString.concat( "0".repeat( maxBitLength - currentBitString.length ) );
    }else {
      // 左側に補完する場合の処理
      return "0".repeat( maxBitLength - currentBitString.length ).concat( currentBitString );
    }
  });
  // テキストエリアに処理結果を反映する
  $("#making_text").val( autoComplementMakingPatternArray.join("\n") );
  // エミュレーション用画面切替と処理結果の反映
   removeInterfaceAndDisplayMakingPattern();
}
