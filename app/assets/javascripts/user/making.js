// "0", "1", "Enter"以外の入力を阻害するメソッド
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
}).on('keyup', '.makings__edit--textarea', function() {
  // エミュレーション画面をプレビュー画面へ切替
  changePreviewMode();
  // テキストエリアの整形とパターン表示への反映
  normalizationMakingPattern();
});


// ボタン除去とプレビュー表示への切替メソッド（パターンに変更があった場合の処理）
function changePreviewMode(  ) {
  // 「変更を保存」ボタンを非表示にする（元々の設定に戻す）
  displayInterfaceAndRemoveSubmit( false );
  // 世代情報を「プレビューを表示中」に切替え
  $(".patterns__show--lifeGameInfo").text( "プレビューを表示中" );
  // アラート表示を全部消す
  callMessageWindow();
}


// 「変更を保存」ボタン、操作ボタン、パターン表示位置切り替えメソッド
function displayInterfaceAndRemoveSubmit( displaying = false, onlySubmitButtonsCange = false ) {
  // 「変更を保存」ボタン
  $("#makings__edit--submit").css({ "display": displaying && "inline-block" || "" });
  // 「変更を保存」ボタン以外のボタン表示も切り替えるか
  if ( ! onlySubmitButtonsCange ) {
    // 各操作ボタン
    $(".patterns__show--lifeGameInterface").css({ "display": ! displaying && "none" || "" });
    // パターン表示を左寄設定
    $(".patterns__show--lifeGameDisplay").css({ "text-align": ! displaying && "left" || "" });
  }
  return false;
}


// ヘッダー直下のアラートを操作するメソッド
function callMessageWindow( kind = "", messages = false ) {
  // 表示されている全てのアラートを非表示にする（元々の設定に戻す）
  $(".application__alert--common").css({ "display": "" });
  // 第１引数にアラートの種類が指定されていればその種類のアラートを表示する
  let selectDivAlert = $(`.application__alert--${ kind }`).css({ "display": "block" });
  // さらに、メッセージがあれば置換する
  switch ( toString.call( messages ) ) {
    // 文字列or数値の場合
    case "[object String]": case "[object Number]":
    selectDivAlert.children("ul").html( `<li>${ messages }</li>` );
    break;

    // 配列で渡された場合
    case "[object Array]":
    selectDivAlert.children("ul").html( `<li>${ messages .join( "</li><li>" )}</li>` );
    break;
  }
}




// 「テキストエリアのテキスト置換」と「そのテキストのプレビュー画面への反映」メソッド
function normalizationMakingPattern( makingPatternArray = false ) {
  // 引数がundefinedの場合は、作成中パターンの「各ビット列の配列」を取得（"0"と"1"以外の文字は除去）
  makingPatternArray = makingPatternArray || getMakingPatternTextareaInfo( true )[0];
  // テキストエリアに反映
  $(".makings__edit--textarea").val( makingPatternArray.join("\n") );
  // セルの状態表示に変換
  let convertMakingPatternArray = makingPatternArray.map( currentbitString => currentbitString.replace( /0/g, "□" ).replace( /1/g, "■" ) );
  // プレビュー画面へ反映
  $(".patterns__show--lifeGameDisplay").html( convertMakingPatternArray.join("<br>") );
}


// 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を計算するメソッド
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
  changePreviewMode();
  // テキストエリアの整形とパターン表示への反映
  normalizationMakingPattern( autoComplementMakingPatternArray );
}


// 適切なパターンかの判定メソッド =>適切なら「変更を保存」ボタンの復活
function verificationMakingPattern() {
  // 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を取得
  let [ makingPatternArray, maxBitLength ] = getMakingPatternTextareaInfo( false );

  // ===バリデーション処理===================================
  let errorMessages = new Array;
  // (1) 最長のビット列の長さが1以上か
  if ( ! maxBitLength ) {
    errorMessages.push("セルがありません。");
  }
  // (2) 各ビット列の長さが等しいか
  if ( ! makingPatternArray.every( currentBitString => currentBitString.length == maxBitLength ) ) {
    errorMessages.push("パターンが不揃いです。");
  }
  // (3) "0"または"1"以外の文字が含まれていないか
  if ( ! makingPatternArray.every( currentBitString => ! /[^01]/.test( currentBitString ) ) ) {
    errorMessages.push("不適切な文字が混入してます。");
  }
  // (4) 「生」セルは存在するか（最初のテストが不通過なら実行しない）
  if ( !! maxBitLength && makingPatternArray.every( currentBitString => ! /1/.test( currentBitString ) ) ) {
    errorMessages.push("「生」セルがありません。");
  }
  // =====================================================
console.log(errorMessages);
  // エラーが存在したか判定
  if ( ! errorMessages.length ) {
    // サクセスメッセージの表示
    callMessageWindow( "success", "保存可能なパターンです。" );
    // 「変更を保存」ボタンの復活処理
    displayInterfaceAndRemoveSubmit( true );
    // 検証を通過したパターンの反映
    initializeLifeGame( makingPatternArray );
    return true;
  }else {
    // エラー検出とエラー内容の表示
    callMessageWindow( "warning", errorMessages );
  }
  return false;
}


// パターンアップデート前のバリデーションメソッド
$(function(){
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  // ここまだ改善必要Making#edit以外も反応するはず
  $("form").submit( function() {
    // 検証に使用するメソッドの返り値で決定
    return verificationMakingPattern();
  });
});
