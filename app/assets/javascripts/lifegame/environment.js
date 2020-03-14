// グローバル変数の定義
// 世代数カウント
var generation_count;
// ライフゲームパターンの初期設定
var pattern_data;
// 繰り返し処理変数
var intervalProcessingID;

// ライフゲーム実行のための初期化メソッド（showページ遷移時に発火）
function initializeLifeGame() {
  // 動作中のライフゲームを強制終了させる
  if ( Number.isFinite( intervalProcessingID ) ) {
    stopProcess();
  }
  // 世代数カウント初期化
  generation_count = 0;
  // ライフゲームのオプション設定
  let options = {
    alive: gon.display_format.alive,
    dead: gon.display_format.dead
  };
  // ライフゲームパターンの初期設定
  pattern_data = new LifeGame(  );
  // 初期盤面の表示
  showingPattern();
}


// ライフゲーム実行処理（開始ボタン押下で発火）
function startProcess() {
  // 繰り返し処理の実行
  intervalProcessingID = setInterval( 'upDate()', 100 );
  // 開始ボタンの無効化
  $("#start-process").prop("disabled", true );
  // 一時停止ボタンの有効化
  $("#stop-process").prop("disabled", false );
}


// ライフゲーム一時停止処理（一時停止ボタン押下で発火）
function stopProcess() {
  // 繰り返し処理の一時停止
  clearInterval( intervalProcessingID );
  // 開始ボタンの有効化
  $("#start-process").prop("disabled", false );
  // 一時停止ボタンの無効化
  $("#stop-process").prop("disabled", true );
}


// 繰り返し処理
function upDate() {
  // 画面上のパターンの更新
  showingPattern()
  // 世代数のカウントアップ
  generation_count++;
  // パターンの世代交代実行
  pattern_data.generationChange;
}


// htmlテキストのインサート処理
function showingPattern() {
  // 表示中のメッセージ更新
  $('#show-info').text( '第' + generation_count + '世代' );
  // 表示中のパターン更新
  $('#show-pattern').html( pattern_data.GetPatternText );
}
