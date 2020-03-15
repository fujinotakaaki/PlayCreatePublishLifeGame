// グローバル変数の定義
// 世代数カウント
var generation_count;
// ライフゲームパターンの初期設定
var pattern_data;
// 繰り返し処理変数
var intervalProcessingID;

// ライフゲーム実行のための初期化メソッド（showページ遷移時に発火）
function initializeLifeGame() {
  // 繰り返し処理実行中の場合を強制終了させる
  if ( Number.isFinite( intervalProcessingID ) ) {
    stopProcess();
  }
  // 世代数カウント初期化
  generation_count = 0;
  // ライフゲームのオプション設定
  let options = {
    // 「生」セルの表示
    alive: gon.display_format.alive,
    // 「死」セルの表示
    dead: gon.display_format.dead
  };
  // ライフゲームの初期化設定
  pattern_data = new LifeGame;
  // pattern_data = new LifeGame( gon.pattern, options );
  // 初期盤面の表示
  showingPattern();
}


// ライフゲーム開始処理（開始ボタン押下で発火）
function startProcess() {
  // 繰り返し処理の開始・再開
  intervalProcessingID = setInterval( 'upDate()', 100 );
  // 開始ボタンの無効化
  $("#start-process").prop("disabled", true );
  // 一時停止ボタンの有効化
  $("#stop-process").prop("disabled", false );
}


// ライフゲーム一時停止処理（一時停止ボタン押下で発火）
function stopProcess() {
  // 繰り返し処理の停止
  clearInterval( intervalProcessingID );
  // 開始ボタンの有効化
  $("#start-process").prop("disabled", false );
  // 一時停止ボタンの無効化
  $("#stop-process").prop("disabled", true );
}


// 繰り返し処理
function upDate() {
  // 画面表示を更新
  showingPattern()
  // 世代数のカウントアップ
  generation_count++;
  // パターンの世代交代実行
  pattern_data.generationChange;
}


// 画面表示の更新処理
function showingPattern() {
  // 表示中のメッセージ更新
  $('#show-info').text( '第' + generation_count + '世代' );
  // 表示中のパターン更新
  $('#show-pattern').html( pattern_data.GetPatternText );
}
