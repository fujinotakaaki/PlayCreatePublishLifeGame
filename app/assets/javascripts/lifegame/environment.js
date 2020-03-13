console.log('Read LifeGame_enviroment.js');

// 一時停止ボタンの無効化
$( function() {
  $("#stopcount").prop("disabled", true );
});
// 世代数
var generation = 0;
// 生きているセルの数を表示するか
const alive_cells_count_show = true;

// ライフゲーム実行処理
function startShowing() {
  // 世代交代の間隔の設定
  PassageID = setInterval( 'upDateLifeGame()', interval );
  // 開始ボタンの無効化
  $("#startcount").prop("disabled", true );
  // 一時停止ボタンの有効化
  $("#stopcount").prop("disabled", false );
}


// ライフゲーム停止処理
function stopShowing() {
  // タイマーのクリア
  clearInterval( PassageID );
  // 開始ボタンの有効化
  $("#startcount").prop("disabled", false );
  // 一時停止ボタンの無効化
  $("#stopcount").prop("disabled", true );
}


// 画面の世代交代処理
function upDateLifeGame( performGenerationChange = true ) {
  // 画面に表示するメッセージ変数の作成
  var msg = '第' + generation + '世代（ No.' + ( life_game_number + 1) + ' : ' + options.name + '）';
  // 生きているセルの情報を取得するか
  if ( alive_cells_count_show ) {
    // 生きているセルの数を取得
    msg +=  ' => 生きているセルの数: ' + life_game.GetAliveCellsCount + '個';
  }
  // メッセージ更新
  $('#ShowInfo').text( msg );
  // 表示中のパターン更新
  $('#ShowLifeGame').html( life_game.GetMap );
  // 世代交代処理
  if ( performGenerationChange ) {
    // 世代数のカウントアップ
    generation++;
    // パターンの世代交代実行
    life_game.UpDate;
  }
}


// パターン変更処理
function next_map() {
  // 世代数の初期化
  generation = 0;
  // サンプルパターンの変更（番号変更）
  life_game_number++;
  // サンプルパターン数を超える場合は0番から
  life_game_number = life_game_number % pattern_count;
  // サンプルパターン名取得
  options.name = pattern[ life_game_number ];
  // ライフゲーム変数の初期化
  life_game = new LifeGame( options );
  // 画面へ反映
  upDateLifeGame( false );
}
