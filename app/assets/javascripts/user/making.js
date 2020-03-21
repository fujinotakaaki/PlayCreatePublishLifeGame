// "0", "1", "Enter"以外の入力を阻害するメソッド（※全角入力は非対応）
$(document).on( 'keypress', '.makings__edit--textarea', function(e) {
  // 押下したキーの種類で処理分岐
  switch ( e.which ) {

    case 13: // "Enter"キー
    // 行数を計算
    let row_count = $(this).val().split("\n").length;
    // テキストエリアの高さ調整
    $( this ).css({ 'height': `${ 5 + ( row_count + 1) * 20 }px` });
    break;

    case 48: case 49: // 0 or 1キー => 入力を許可
    break;

    default: // その他 =>入力を阻害
    return false;
  }
}).on('keyup', function() {
  // エミュレーション画面をプレビュー画面へ切替
  removeInterfaceAndChangindPreviewWindow();
  // テキストエリアの整形とパターン表示への反映
  normalizationMakingPattern();
});

// ボタン除去とプレビュー表示への切替処理（パターンに変更があった場合の処理）
function removeInterfaceAndChangindPreviewWindow() {
  // 編集内容に合わせてリアルタイムにパターンへ反映させる
  $(".patterns__show--lifeGameDisplay").css({ "text-align": "left" });
  // 世代情報を「プレビューを表示中」に切替え
  $(".patterns__show--lifeGameInfo").text( "プレビューを表示中" );
  // 操作ボタンの削除（編集中のパターンはエミュレートできないため）
  $(".patterns__show--lifeGameInterface").text('');
  // 「変更を保存」ボタンを非表示にする（元々の設定に戻す）
  $(".makings__edit--submit").css({ "display": "" });
}

function normalizationMakingPattern( makingPatternArray = undefined ) {
  // 引数がundefinedの場合は、作成中パターンの「各ビット列の配列」を取得（"0"と"1"以外の文字は除去）
  makingPatternArray = makingPatternArray || getMakingPatternTextareaInfo( true )[0];
  // console.log(makingPatternArray.join("unko"));
  // テキストエリアに反映
  $(".makings__edit--textarea").val( makingPatternArray.join("\n") );
  // セルの状態表示に変換
  let convertMakingPatternArray = makingPatternArray.map( currentbitString => currentbitString.replace( /0/g, "□" ).replace( /1/g, "■" ) );
  // プレビュー画面へ反映
  $(".patterns__show--lifeGameDisplay").html( convertMakingPatternArray.join("<br>") );
}

// パターンのビット長を揃えるためのメソッド
function autoComplement( side ) {
  // 右側に補完するか判定（falseなら左側に補完）
  let autoCompleteToRightSide = /right/.test( side );
  // 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を取得
  let [ makingPatternArray, maxBitLength ] = getMakingPatternTextareaInfo( true );
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
  // エミュレーション画面をプレビュー画面へ切替
  removeInterfaceAndChangindPreviewWindow();
  // テキストエリアの整形とパターン表示への反映
  normalizationMakingPattern( autoComplementMakingPatternArray );
}

// 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を計算する処理
function getMakingPatternTextareaInfo( normalization = true ) {
  // テキストエリアのテキストを行区切りで配列化
  let makingPatternArray = $(".makings__edit--textarea").val().split("\n");
  if ( normalization ) {
    // 全ビット列に対して"0"と"1"以外の文字を除去する処理
    makingPatternArray = makingPatternArray.map( currentbitString => currentbitString.replace( /[^01]/g, "" ) );
  }
  // 最長の文字列の文字数を取得
  let maxBitLength = makingPatternArray.reduce( ( max, currentBitString ) => ( max < currentBitString.length ? currentBitString.length : max ), 0 );
  // 第1引数…各ビット列の配列
  // 第2引数…最長のビット列の長さ
  // normalization = falseの場合は"0"と"1"以外の文字も含めて処理される
  return [ makingPatternArray, maxBitLength ];
}

// 適切なパターンかの判定メソッド =>適切なら「変更を保存」ボタンの復活
function verificationMakingPattern() {
  // 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を取得
  let [ makingPatternArray, maxBitLength ] = getMakingPatternTextareaInfo( false );
  // 「最長のビット列の長さが1以上」かつ「各ビット列の長さが等しい」か判定
  easyValidation = maxBitLength && makingPatternArray.every( currentBitString => currentBitString.length == maxBitLength );
  if ( easyValidation ) { // easyValidation = true
    // 「変更を保存」ボタンの復活
    $(".makings__edit--submit").css({ "display": "inline-block"});
  }else {
    // パターンとして不適切な場合
    if ( Number.isInteger( easyValidation ) ) { // easyValidation = 0
      // 最長のビット列の長さが0の場合 => セルが存在しない場合
      alert("セルがありません。");
    }else { // easyValidation = false
      // パターンの幅が不揃いの場合
      alert("パターンの幅が不揃いです。");
    }
  }
}
