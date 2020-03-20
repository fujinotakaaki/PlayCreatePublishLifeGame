// グローバル変数の定義
// 世代数カウント
var generationCount;
// ライフゲームを定義する変数
var patternData;
// 繰り返し処理の変数
var intervalProcessingID;
// ライフゲーム変数の初期化メソッド（patterns/emulation.html.erb呼出時orリフレッシュボタンで発火）
// makingPatternArrayはパターンを作成し、画面に反映させる際に使用される
function initializeLifeGame( makingPatternArray = undefined ) {
  // 繰り返し処理実行中の場合は強制終了させる
  if ( Number.isInteger( intervalProcessingID ) ) {
    stopProcess();
  }
  // 世代数カウント初期化
  generationCount = 0;
  // options変数の生成（ライフゲームの表示形式に関する設定）
  let options;
  // 表示形式情報があればoptions変数に設定情報を格納
  if ( !!gon.displayFormat ) {
    options = {
      // 「生」セルの表示
      alive: gon.displayFormat.alive,
      // 「死」セルの表示
      dead: gon.displayFormat.dead,
      // 平坦トーラス面として扱うか
      isTorus: gon.isTorus
    };
    // セルの表示情報を画面に適用
    applyDisplayFormat();
  }
  // ライフゲームの初期化設定
  patternData = new LifeGame( makingPatternArray || gon.pattern, options );
  // 初期盤面の表示
  showCurrentGeneration();
}


// ライフゲーム開始処理（開始ボタン押下で発火）
function startProcess() {
  // 繰り返し処理の開始・再開
  intervalProcessingID = setInterval( 'upDate()', 300 );
  // ボタン押下可否の切り替え
  buttonsFreezeOrRelease( true );
}


// ライフゲーム一時停止処理（一時停止ボタン押下で発火）
function stopProcess() {
  // 繰り返し処理の停止
  clearInterval( intervalProcessingID );
  // ボタン押下可否の切り替え
  buttonsFreezeOrRelease( false );
}


// 繰り返し処理
function upDate() {
  // 画面表示を更新
  showCurrentGeneration()
  // 世代数のカウントアップ
  generationCount++;
  // パターンの世代交代実行
  patternData.generationChange;
}


// 画面表示の更新処理
function showCurrentGeneration() {
  // 表示中のメッセージ更新
  $('.patterns__show--lifeGameInfo').text( '第' + generationCount + '世代' );
  // 表示中のパターン更新
  $('.patterns__show--lifeGameDisplay').html( patternData.getPatternText );
}

// ボタン押下可否の切り替え
function buttonsFreezeOrRelease( bool ) {
  // 開始ボタン
  $(".patterns__show--lifeGameStart").prop("disabled", bool );
  // 一時停止ボタン
  $(".patterns__show--lifeGameStop").prop("disabled", ! bool );
  // リフレッシュボタン
  $(".patterns__show--lifeGameRefresh").prop("disabled", bool );
  // Making#editのsubmitボタン
  $(".makings__edit--submit").prop("disabled", bool );
}

// セル表示状態をCSSを通して適用
function applyDisplayFormat() {
  // jQueryによって適用
  $('.patterns__show--lifeGameDisplay').css({
    'color': `${ gon.displayFormat.font_color }`,
    'background-color': `${ gon.displayFormat.background_color }`,
    'line-height': `${ gon.displayFormat.line_height_rate / 100 }`
  });
}
