// Makingコントローラーで使用されるメソッド類

/*
* =============================
* "0", "1", "Enter"以外の入力を阻害するメソッド
* =============================
*/
$(document).on( 'keypress', '.makings__edit--textarea', function(e) {
  // 押下したキーの種類で処理分岐
  switch ( e.which ) {

    case 13: // "Enter"キー
    // 行数を計算
    // let row_count = $(this).val().split("\n").length;
    // テキストエリアの高さ調整（動くのが煩わしいと考え、一時無効）
    // $( this ).css({ 'height': `${ 5 + ( row_count + 1) * 20 }px` });
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
  applyMakingPattern();
});


/*
* =============================
* ボタン除去とプレビュー表示への切替メソッド（パターンに変更があった場合の処理）
* =============================
*/
function changePreviewMode() {
  // 繰り返し処理の停止
  stopProcess();
  // アラート表示を全部消す（user/application.js）
  callMessageWindow();
  // 「変更を保存」ボタンを非表示にする（元々の設定に戻す）
  displayInterface( false );
  // 世代情報を「プレビューを表示中」に切替え
  $(".patterns__show--lifeGameInfo").text( "プレビューを表示中" );
}


/*
* =============================
* 画面表示切替関連のメソッド
* ライフームの操作ボタン、「変更を保存」ボタン、「パターン投稿」ボタン、プレビュー表示の切替
* =============================
*/
function displayInterface( displaying = false, displayPatternJumpButton = false ) {
  // 「変更を保存」ボタン（※デフォルトは非表示）
  $("#makings__edit--update").css({ "display": displaying && "inline-block" || "" });
  // 各操作ボタン
  $(".patterns__show--lifeGameInterface").css({ "display": ! displaying && "none" || "" });
  // 上下左右反転・回転ボタン
  $(".makings__edit--preview").prop( "disabled", ! displaying );
  // 合成パターン選択ウィンドウ
  $("#coupler_selection").prop( "disabled", ! displaying );
  // 合成パターン決定ボタン
  $(".makings__edit--startCoupling").prop( "disabled", true );
  // パターン表示を左寄せ
  $(".patterns__show--lifeGameDisplay").css({ "text-align": ! displaying && "left" || "" });
  // パターンの「新規投稿」ボタンは変更があれば常に非表示（※デフォルトは非表示）
  // Making#updateが成功した場合のみ表示される(views/makings/update.js.erb)
  $("#patterns__new--jump").css({ "display": displayPatternJumpButton && "inline-block" || "" });
}

/*
* =============================
* 「テキストエリアのテキスト置換」と「そのテキストのプレビュー画面への反映」メソッド
* =============================
*/
function applyMakingPattern( makingPatternArray = false ) {
  // 引数がない場合は、作成中のパターンを配列として取得（"0"と"1"以外の文字は除去）
  makingPatternArray = makingPatternArray || getMakingPatternTextareaInfo( true )[0];
  // テキストエリアに反映
  $(".makings__edit--textarea").val( makingPatternArray.join("\n") );
  // セルの状態表示に変換＆プレビュー画面へ変更の反映
  $(".patterns__show--lifeGameDisplay").html( LifeGame.convertPatternText( makingPatternArray ) );
}

/*
* =============================
* 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を計算するメソッド
* =============================
*/
function getMakingPatternTextareaInfo( normalization = true ) {
  // テキストエリアのテキストを行区切りで配列化
  let makingPatternArray = $(".makings__edit--textarea").val().split("\n");
  if ( normalization ) {
    // 全ビット列に対して"0"と"1"以外の文字を除去する処理
    makingPatternArray = makingPatternArray.map( bitString =>
      bitString.replace( /[^01]/g, "" )
    );
  }
  // 最長の文字列の文字数を取得
  let maxBitLength = makingPatternArray.reduce( ( max, currentBitString ) =>
  ( max < currentBitString.length ? currentBitString.length : max ),
  0 );
  // 第1引数…各ビット列の配列
  // 第2引数…最長のビット列の長さ
  // normalization = falseの場合は"0"と"1"以外の文字も含めて処理される
  return [ makingPatternArray, maxBitLength ];
}

/*
* =============================
* 作成中パターンのビット長方向に補完するメソッド
* =============================
*/
function autoComplement( side ) {
  // 右側に補完するか判定（falseなら左側に補完）
  let autoCompleteToRightSide = /right/.test( side );
  // 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を取得
  let [ makingPatternArray, maxBitLength ] = getMakingPatternTextareaInfo( true );
  // 横方向に対するビットの補完処理（0で補完）
  let autoComplementMakingPatternArray = makingPatternArray.map( function( bitString ) {
    if ( autoCompleteToRightSide ) {
      // 右側に補完する場合の処理
      return bitString.concat( "0".repeat( maxBitLength - bitString.length ) );
    }else {
      // 左側に補完する場合の処理
      return "0".repeat( maxBitLength - bitString.length ).concat( bitString );
    }
  });
  // エミュレーション画面をプレビュー画面へ切替
  changePreviewMode();
  // テキストエリアの整形とパターン表示への反映
  applyMakingPattern( autoComplementMakingPatternArray );
}

/*
* =============================
* 作成中パターンのバリデーションメソッド
* =============================
*/
function verificationMakingPattern() {
  // 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を取得
  let [ makingPatternArray, maxBitLength ] = getMakingPatternTextareaInfo( false );

  // ### バリデーション処理 #####################
  let errorMessages = new Array;
  // (1) 最長のビット列の長さが1以上か
  let test1 = ! maxBitLength;
  if ( test1 ) {
    errorMessages.push("セルがありません。");
  }
  // (2) 各ビット列の長さが等しいか
  let test2 = ! makingPatternArray.every( bitString => bitString.length == maxBitLength );
  if ( test2 ) {
    errorMessages.push("パターンが不揃いです。");
  }
  // (3) "0"または"1"以外の文字が含まれていないか
  let test3 = ! makingPatternArray.every( bitString => ! /[^01]/.test( bitString ) );
  if ( test3 ) {
    errorMessages.push("不適切な文字が混入してます。");
  }
  // (4) 「生」セルは存在するか（最初のテストが不通過なら実行しない）
  let test4 = ! test1 && makingPatternArray.every( bitString => ! /1/.test( bitString ) );
  if ( test4 ) {
    errorMessages.push("「生」セルがありません。");
  }
  // #########################################

  // エラーが存在したか判定
  if ( !! errorMessages.length ) {
    // エラー検出とエラー内容の表示（user/application.js）
    callMessageWindow( "warning", errorMessages );
    // バリデーション結果を返す
    return false;
  }

  // サクセスメッセージの表示（user/application.js）
  callMessageWindow( "info", "保存可能なパターンです。" );
  // 「変更を保存」ボタンの復活処理
  displayInterface( true );
  // 検証を通過したパターンの反映（lifegame/environments.js）
  initializeLifeGame( makingPatternArray );
  // バリデーション結果を返す
  return true;
}

/*
* =============================
* パターンの上下左右反転・回転実行メソッド
* =============================
*/
function touchingMmakingPattern( n = 0 ) {
  switch (n) {
    // 上下反転
    case 1:
    patternData.flipVertical;
    break;

    // 左右反転
    case 2:
    patternData.flipHorizontal;
    break;

    // 反時計回りに４５度回転
    case 3:
    patternData.rotateCounterClockwise;
    break;

    default:
    return false;
  }
  // テキストエリアへの反映
  applyMakingPattern( patternData.patternInitial );
  // 現在の状態反映（javascripts/lifegame/environments.js）
  showCurrentGeneration();
}


/*
* =============================
* パターンの上下の行または各ビット列の端のセル追加・削除メソッド
* =============================
*/
function touchingLine( n = 0 ) {
  // 作成中パターンの「各ビット列の配列」と「最長のビット列の長さ」を取得
  let [ makingPatternArray, maxBitLength ] = getMakingPatternTextareaInfo( false );
  // 追加・削除処理の分岐
  switch (n) {
    // 行を追加
    // 先頭に行を追加
    case 1:
    makingPatternArray.unshift( '0'.repeat( maxBitLength ) );
    break;

    // 後尾に行を追加
    case 2:
    makingPatternArray.push('0'.repeat( maxBitLength ) );
    break;

    // 左に行を追加
    case 3:
    makingPatternArray = makingPatternArray.map( ( bitString ) => '0' + bitString );
    break;

    // 右に行を追加
    case 4:
    makingPatternArray = makingPatternArray.map( ( bitString ) => bitString + '0' );
    break;

    // 行を削除
    case 5: case 6:
    // 5なら最初の行を、6なら最後の行を削除
    n == 5 ? makingPatternArray.shift() : makingPatternArray.pop();
    break;

    //列を削除
    case 7: case 8:
    makingPatternArray = makingPatternArray.map( function( bitString ) {
      // 最長でないビット列については処理を実行しない
      if ( bitString.length == maxBitLength ) {
        // 7なら最初のセルを、8なら最後のセルを削除
        return n == 7 ? bitString.slice(1) : bitString.slice(0, -1);
      }
      return bitString;
    });
    break;

    default:
    return false;
  }
  // エミュレーション画面をプレビュー画面へ切替
  changePreviewMode();
  // テキストエリアの整形とパターン表示への反映
  applyMakingPattern( makingPatternArray );
}


/*
* =============================
* パターン合成処理まとめ
* =============================
*/
function changeCouplingMode(state) {
  // ===== coupler選択時処理 ===============
  function selectCoupler() { // 'select'の処理
    let pattern_id = $("#coupler_selection").val();
    // promptの値は無効
    if ( ! pattern_id ) return false;
    // IDからPatternデータを取得
    $.ajax({
      url: `/patterns/${ pattern_id }`,
      type: 'get',
      dataType : 'json'
    }).then(

      // 通信成功時のコールバック
      function(data) {
        console.log("通信成功");

        // 合成するパターンの入力 => 入力結果を取得
        let settingTest = patternData.setCoupler( data.couplerPattern );
        // 合成の可否によってボタンの状態を変化させる
        $(".makings__edit--startCoupling").prop( "disabled", ! settingTest );
        // couplerのプレビューを表示
        $(".makings__edit--couplerPreview").html( patternData.coupler.getPatternText );
      },

      // 通信失敗時のコールバック
      function() {
        alert("通信失敗");

        // 合成の可否によってボタンの状態を変化させる
        $(".makings__edit--startCoupling").prop( "disabled", true);
        // couplerのプレビューを表示
        $(".makings__edit--couplerPreview").text("");
      }
    );
  }

  // ===== 合成モード起動時処理 ===============
  function startUpCouplingMode() {
    // 手順１から手順２へ表示を切り替え
    $(".makings__edit--couplingDiv1").fadeOut( function(){
      $(".makings__edit--couplingDiv2").fadeIn();
    });

    // 母体パターンの表示切り替え処理
    $(".patterns__show--lifeGameDisplay").fadeOut( function() {
      // プレビュー状態へ切替
      changePreviewMode();
      // 合成プレビューを表示
      $(this).html( patternData.couplingPreview() ).fadeIn();
    });

    // couplerの十字キー操作の移動効果付与
    $(window).off().on('keydown', function(e) {
      // 十字キーでのスクロール無効
      e.preventDefault();
      // 合成するパターンの移動方向検出・移動
      switch (e.keyCode) {
        case 37: // ←
        patternData.movePutPosition([0,-1]);
        break;
        case 38: // ↑
        patternData.movePutPosition([-1,0]);
        break;
        case 39: // →
        patternData.movePutPosition([0,1]);
        break;
        case 40: // ↓
        patternData.movePutPosition([1,0]);
        break;
      }
      // 処理後の合成プレビューを表示
      $(".patterns__show--lifeGameDisplay").html(patternData.couplingPreview());
    });
  }


  // ===== 合成モード修了時処理 ===============
  function finishCoupulingMode() {
    // 合成するパターンの十字キー操作解除
    $(window).off();
    // 母体パターンに合成パターンの反映実行
    patternData.couplingPreview({ finishCoupling: true });
    // テキストエリアへの反映
    applyMakingPattern( patternData.patternInitial );
    // 合成パターン選択ウィンドウ選択許可（連続操作の場合のみOKとしたいため）
    $("#coupler_selection").prop( "disabled", false );
    // 合成パターン決定ボタン押下許可（連続操作の場合のみOKとしたいため）
    $(".makings__edit--startCoupling").prop( "disabled", false );
    // 手順２から手順１へ表示を切り替え
    $(".makings__edit--couplingDiv2").fadeOut( function(){
      $(".makings__edit--couplingDiv1").fadeIn();
    });
  }

  // ===== 合成モード分岐処理 ===============
  switch (state) {
    case 'select': // coupler選択処理
    selectCoupler();
    break;
    case 'start': // 起動処理
    startUpCouplingMode();
    break;
    case 'finish': // 修了処理
    finishCoupulingMode();
    break;
  }
}
