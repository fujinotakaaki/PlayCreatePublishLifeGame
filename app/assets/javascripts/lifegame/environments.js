// グローバル変数の定義
// ライフゲームを定義する変数
var patternData;
// 繰り返し処理の変数
var intervalProcessingID;


// ライフゲーム変数の初期化メソッド
// 第１引数・・・変数中のパターンをpatternDataに適用する（gonよりも優先される）
// 第２引数・・・定義されているpatternDataを初期状態に戻す（第１引数及びgonに影響されない）
// 第３引数・・・定義されているpatternDataの表示形式を変更する（第２引数と併用可能）
function initializeLifeGame( applyMakingPattern = false, refreshLifeGame = false, changeDisplayFormat = false ) {
  // 実行中のライフゲームを強制終了させる
  if ( !! intervalProcessingID ) {
    // 繰り返し処理の停止
    stopProcess();
  }

  // ライフゲームの初期設定（引数が設定されている場合は実行されない）
  if ( ! applyMakingPattern && ! refreshLifeGame && ! changeDisplayFormat ) {
    // 新規盤面の設定（第２引数はトーラス面フラグ(isTorus)のみ設定が反映可能）
    patternData = new LifeGame( gon.pattern );
    // セルの表示定義（alive, dead）の変更処理
    patternData.changeCellConditions( gon.cellConditions );
    // cssの設定情報を画面に適用
    applyCssOptions( gon.cssOptions );
    // トーラス面設定の変更処理
    patternData.changeTorusFlag( gon.isTorus );
  }

  // 作成中のパターンの反映のみ実行
  if ( !! applyMakingPattern ) {
    // 定義済みのライフゲーム変数から破壊的にトーラスフラグを取得
    let currentIsTorusCondition = ! patternData.changeTorusFlag();
    // ライフゲーム変数の再定義
    patternData = new LifeGame( applyMakingPattern );
    // トーラス面設定の変更処理
    patternData.changeTorusFlag( currentIsTorusCondition );
  }

  // ライフゲームの初期化処理
  if ( !! refreshLifeGame ) {
    // 定義済み盤面の初期化
    patternData.patternRefresh;
  }

  // セルの表示状態変更処理
  if ( !! changeDisplayFormat ) {
    // セルの表示定義の変更処理
    patternData.changeCellConditions( changeDisplayFormat.cellConditions );
    // cssの設定情報を画面に適用
    applyCssOptions( changeDisplayFormat.cssOptions );
  }

  // 現在の状態反映
  showCurrentGeneration();
}


// ライフゲーム画面のCSS設定を変更するメソッド
function applyCssOptions( cssOptions = { fontColor: "limegreen", backgroundColor: "black", fontSize: 30, lineHeightRate: 60, letterSpacing: 0 } ) {
  // jQueryによって適用
  $('.patterns__show--lifeGameDisplay').css({
    // 文字色の変更
    'color':                     `${ cssOptions.fontColor }`,
    // 背景色の変更
    'background-color': `${ cssOptions.backgroundColor }`,
    // 垂直方向の文字間隔の変更
    'font-size':               `${ cssOptions.fontSize }px`,
    // 垂直方向の文字間隔の変更
    'line-height':            `${ cssOptions.lineHeightRate }%`,
    // 横方向の文字間隔の変更
    'letter-spacing':       `${ cssOptions.letterSpacing }px`
  });
}


// 画面表示の更新処理
function showCurrentGeneration() {
  // 表示中のメッセージ更新
  $('.patterns__show--lifeGameInfo').text( '第' + patternData.generationCount + '世代' );
  // 表示中のパターン更新
  $('.patterns__show--lifeGameDisplay').html( patternData.getPatternText );
}


// ライフゲーム開始処理（開始ボタン押下で発火）
function startProcess( intervalTime = 300 ) {
  // 繰り返し処理の開始・再開
  intervalProcessingID = setInterval( 'upDate()', intervalTime );
  // ボタン押下可否の切り替え
  buttonsFreezeOrRelease( true );
}


// 繰り返し処理
function upDate() {
  // パターンの世代交代実行
  patternData.generationChange;
  // 画面表示を更新
  showCurrentGeneration()
}


// ライフゲーム一時停止処理（一時停止ボタン押下で発火）
function stopProcess() {
  // 繰り返し処理の停止
  clearInterval( intervalProcessingID );
  // ボタン押下可否の切り替え
  buttonsFreezeOrRelease( false );
}


// ボタン押下可否の切り替え
function buttonsFreezeOrRelease( bool = true ) {
  // 画面上の全てのボタンの押下状態の変更
  $("[type = button]").prop( "disabled", bool );
  // 「一時停止」ボタンのみ、状態を逆転
  $(".patterns__show--lifeGameStop").prop( "disabled", ! bool );
}
