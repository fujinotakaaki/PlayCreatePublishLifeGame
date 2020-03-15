class LifeGame {
  // 世代交代後のパターン
  new_map = new Array;

  // パターン情報と表示形式情報のインプット
  constructor( pattern = ["...............", "...............", "...............", "...##.######...", "...##.######...", "...##..........", "...##.....##...", "...##.....##...", "...##.....##...", "..........##...", "...######.##...", "...######.##...", "...............", "...............", "..............."],
  options = { alive: '#', dead: '.' } ) {
    // 初期パターン取得
    this.map = pattern;
    // パターン定義域取得
    [ this.height, this.width ] = [ pattern.length, pattern[0].length ];
    // セル状態の定義取得
    [ this.alive, this.dead ] = [ options.alive, options.dead ];
  }

  // パターンのHTMLテキスト出力メソッド
  get GetPatternText() {
    // ビット列を表示形式に変換
    // this.ChangeInitialMap();
    // HTMLテキストとして返す
    return this.map.join( '<br>' );
  }

  // 世代交代処理メソッド
  get generationChange() {
    // パターン（配列）の行インデックス番号
    for ( let y = 0; y < this.height; y++ ) {
      let row = new String;
      // パターンの各セル（配列の要素１個１個）を処理
      for ( let x = 0; x < this.width; x++ ) {
        row = row.concat( this.DeadOrAlive( y, x ) );
      }
      // 各行の操作が終了したら新世代配列に追加
      this.new_map.push( row );
    }
    // 新世代を現在世代に反映
    this.map = this.new_map;
    // 新世代配列
    this.new_map = new Array;
  }


  // セルの誕生、生存、過疎、過密処理
  DeadOrAlive( y, x ) {
    // 周辺セル座標の配列取得
    var around = this.AroundCombination( y, x );
    // 調査対象セルのうち生きたセルの数
    var cell_count = 0;
    // 周辺セルの調査
    while ( around.length != 0 ) {
      var [ t, s ] = around.shift();
      // 生きたセルがあればカウントアップ
      if ( this.InOrOut( t, s ) && this.map[t][s]==this.alive ) { cell_count++; }
    }
    // 返す値のデフォルトの設定
    var str = this.dead;
    // 次世代の対象セルの状態決定
    if ( cell_count==3 || ( cell_count==2 && this.map[y][x]==this.alive ) ) { str = this.alive; }
    return str;
  }
  // 周辺セル座標の配列作成
  AroundCombination( y, x ) {
    var arr = new Array;
    for ( let t = -1; t <= 1; t++ ) {
      for ( let s = -1; s <= 1; s++ ) {
        if ( s!=0 || t!=0 ) { arr.push( [ y+t, x+s ] ); }
      }
    }
    return arr;
  }

  // マップ内外判定
  InOrOut( y, x ) {
    // はみ出してたらfalseにしたい
    return (0<=y && y<this.height && 0<=x && x<this.width);
  }

  // 初期パターンの書式変換
  ChangeInitialMap() {
    console.log( 'Rebuilding map' );
    // パターン更新後の格納変数
    var apply_format_map = new Array;
    // 更新前のパターンの各行
    var row1 = new Array;
    // 更新前のパターンの各行を配列にsplitしたもの
    var row2 = new String;
    // 生状態表示
    const alive = this.alive;
    // 死状態表示
    const dead = this.dead;
    // 変更する文字列を格納する変数
    var char = new String
    // 各行取得処理
    while ( this.map.length !=0 ) {
      // 各行取得
      row1 = this.map.shift()
      // row1書き出し
      // console.log('row1=', row1);
      // 各行配列化合
      row2 = row1.split('');
      // row2書き出し
      // console.log('row2=', row2);
      // 更新後の行の文字列化
      var row3 = new String;
      // 文字列化された行を先頭から処理
      while ( row2.length != 0 ) {
        // 変換する文字の決定
        if ( row2.shift() == '#' ) { char = alive; }
        else { char = dead; }
        // 更新後の行にセルの状態を追加
        row3 = row3.concat( char )
      }
      // row3書き出し
      // console.log('row3=', row3);
      apply_format_map.push( row3 )
    }
    // console.log('finish');
    this.map = apply_format_map;
    // console.log( apply_format_map.join("\n") );
  }
} // class
