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
  removeInterfaceAndReplacePreviewWindow();
  // テキストエリアの整形とパターン表示への反映
  normalizationMakingPattern();
});


// ボタン除去とプレビュー表示への切替メソッド（パターンに変更があった場合の処理）
function removeInterfaceAndReplacePreviewWindow() {
  // 「変更を保存」ボタンを非表示にする（元々の設定に戻す）
  makingPatternSubmitButtonDisplay( false );
  // 操作ボタンの削除（編集中のパターンはエミュレートできないため）
  $(".patterns__show--lifeGameInterface").text('');
  // 世代情報を「プレビューを表示中」に切替え
  $(".patterns__show--lifeGameInfo").text( "プレビューを表示中" );
  // 編集内容に合わせてリアルタイムにパターンへ反映させる
  $(".patterns__show--lifeGameDisplay").css({ "text-align": "left" });
  // アラート表示を全部消す
  callMessageWindow();
}

// 「変更を保存」ボタン表示切り替えメソッド
function makingPatternSubmitButtonDisplay( bool ) {
  // trueなら表示
  $("#makings__edit--submit").css({ "display":
  bool && "inline-block" || ""
});
}


// ヘッダー直下のアラートを操作するメソッド
function callMessageWindow( kind = "", messages = "" ) {
  // 表示されている全てのアラートを非表示にする（元々の設定に戻す）
  $(".application__alert--common").css({ "display": "" });
  // 第１引数にアラートの種類が指定されていればその種類のアラートを表示する
  if ( !! kind ) {
    let selectDivAlert = $(`.application__alert--${ kind }`).css({ "display": "block" });
    // さらに、メッセージがあれば置換する
    if ( !! messages ) { selectDivAlert.children("p").html( messages ); }
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
  removeInterfaceAndReplacePreviewWindow();
  // テキストエリアの整形とパターン表示への反映
  normalizationMakingPattern( autoComplementMakingPatternArray );
}


// 適切なパターンかの判定メソッド =>適切なら「変更を保存」ボタンの復活
function verificationMakingPattern() {
  // 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を取得
  let [ makingPatternArray, maxBitLength ] = getMakingPatternTextareaInfo( false );

  // ===バリデーション処理===================================
  let errorMessages = "";
  // (1) 最長のビット列の長さが1以上か
  if ( ! maxBitLength ) {
    errorMessages += "・セルがありません。<br>";
  }
  // (2) 各ビット列の長さが等しいか
  if ( ! makingPatternArray.every( currentBitString => currentBitString.length == maxBitLength ) ) {
    errorMessages += "・パターンが不揃いです。<br>";
  }
  // (3) "0"または"1"以外の文字が含まれていないか
  if ( ! makingPatternArray.every( currentBitString => ! /[^01]/.test( currentBitString ) ) ) {
    errorMessages += "・不適切な文字が混入してます。<br>";
  }
  // (4) 「生」セルは存在するか
  if ( makingPatternArray.every( currentBitString => ! /1/.test( currentBitString ) ) ) {
    errorMessages += "・「生」セルがありません。<br>";
  }
  // =====================================================

  // エラーが存在したか判定
  if ( ! errorMessages ) {
    // 「変更を保存」ボタンの復活処理
    makingPatternSubmitButtonDisplay( true )
    // サクセスメッセージの表示
    callMessageWindow( "success", "保存可能なパターンです。" );
    return true;
  }else {
    // エラー検出とエラー内容の表示
    callMessageWindow( "warning", errorMessages );
  }
  return false;
}

// パターンアップデート前のバリデーションメソッド
$(function(){
  $("#makings__edit--submit").on( "click", function() {
    // バリデーション処理の結果によって送信・中止を決定
    // return verificationMakingPattern();
    return false;
  });
});
