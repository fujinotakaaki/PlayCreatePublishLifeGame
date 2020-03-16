class LifeGame {
  // 世代交代後の盤面
  newPattern = new Array;

  // 盤面情報と表示形式情報の設定
  constructor( pattern = [ "0000", "0110", "0110", "0000" ], options = { alive: '■', dead: '□', isTorus: false} ) {
    // 初期盤面の取得（要素がビット列の１次元配列）
    this.pattern = pattern;
    // 盤面の定義域取得
    [ this.height, this.width ] = [ pattern.length, pattern[0].length ];
    // セル状態の表示を定義
    [ this.alive, this.dead ] = [ options.alive, options.dead ];
    // 平坦トーラス面として扱うかのフラグ設定
    this.isTorus = options.isTorus;
  }

  // 盤面のHTMLテキストへの出力メソッド
  get getPatternText() {
    // ビット列を表示形式に変換して返す（ 不具合①：this.alive = '0'だと正しく変換できない）
    return this.pattern.map( str => str.replace( /1/g, this.alive).replace( /0/g, this.dead) ).join( '<br>' );
  }

  // 世代交代の処理メソッド
  get generationChange() {
    // 配列のインデックス番号を生成
    for ( let y = 0; y < this.height; y++ ) {
      // 世代更新後の盤面のy行目のビット列を格納する変数
      let row = new String;
      // y行目の各セルを処理
      for ( let x = 0; x < this.width; x++ ) {
        // 座標(x,y)のセル( this.pattern[y][x] )の次世代の状態を取得・保存（"0" or "1"を追記）
        row += this.deadOrAlive( y, x );
      }
      // y行目の処理が済んだら、次世代盤面へ（配列）追加
      this.newPattern.push( row );
    }
    // 次世代パターンを現在世代パターンに反映
    this.pattern = this.newPattern;
    // 次世代パターン（配列）の初期化
    this.newPattern = new Array;
  }


  // セルの誕生、生存、過疎、過密処理
  deadOrAlive( y, x ) {
    // (1) 周辺セル（８ヵ所）の座標生成
    let mooreNeighborhood = [ [1,1], [1,0], [1,-1], [0,1], [0,-1], [-1,1], [-1,0], [-1,-1] ]

    let aliveCellsCount = 0;
    // (2) 周辺の生きているセルのカウントアップ（マップ外は「死」扱い）
    for ( let [ t, s ] of mooreNeighborhood ) {
      // セルの状態は文字列のため、数値に変換必須
      aliveCellsCount +=  Number( this.pattern?.[ y+t ]?.[ x+s ]
        || ( this.isTorus ? this.pattern[ ( y + t + this.height ) % this.height ][ ( x + s + this.width ) % this.width ] : 0 ) );
        // ※平坦トーラス面の場合は循環先のセル状態を考慮する
    }

    // (3) 世代更新後の中心座標のセルの生死状態判定
    // ひとまず次世代では「死」と仮定
    let nextCondition = 0;
    // 次世代で「生」になる可能性があるか判定
    if ( /0/.test( this.pattern[y][x] ) ) {
      // 元々死の状態だった場合 => 誕生するか判定
      if ( /3/.test( aliveCellsCount ) ) { nextCondition = 1; }
    } else {
      // 元々生の状態だった場合 => 生存するか判定
      if ( /2|3/.test( aliveCellsCount ) ) { nextCondition = 1; }
    }
    // 次世代での状態を返す => "0" or "1"
    return String( nextCondition );
  }
} // class
