class LifeGame {
  // 世代交代後のパターン
  new_pattern = new Array;

  // パターン情報と表示形式情報のインプット
  constructor( pattern = [ "0000", "0110", "0110", "0000" ], options = { alive: '■', dead: '□', is_torus: false} ) {
    // 初期パターン取得
    this.pattern = pattern;
    // パターン定義域取得
    [ this.height, this.width ] = [ pattern.length, pattern[0].length ];
    // セル状態の定義取得
    [ this.alive, this.dead ] = [ options.alive, options.dead ];
    // 平坦トーラス面として扱うかのフラグ
    this.isTorus = options.is_torus;
  }

  // パターンのHTMLテキスト出力メソッド
  get GetPatternText() {
    // HTMLテキストとして返す
    return this.pattern.map( str => str.replace( /1/g, this.alive).replace( /0/g, this.dead) ).join( '<br>' );
  }

  // 世代交代処理メソッド
  get GenerationChange() {
    // パターン（配列）の行番号y
    for ( let y = 0; y < this.height; y++ ) {
      // 世代更新後のパターンのy行目について、ビット列を格納する変数
      let row = new String;
      // パターンの各セル（配列の要素１個１個）を処理
      for ( let x = 0; x < this.width; x++ ) {
        // 座標(x,y)のセル( this.pattern[y][x] )の世代更新後の状態を取得・保存 => "0"or"1"を追記
        // console.log(`DeadOrAlive(x,y) = (${x},${y})`);
        row += this.DeadOrAlive( y, x );
      }
      // 更新後の行が確定したら新世代のパターン（配列）に追加
      this.new_pattern.push( row );
    }
    // 新世代パターンを現在世代パターンに反映
    this.pattern = this.new_pattern;
    // 新世代パターン（配列）の初期化
    this.new_pattern = new Array;
  }


  // セルの誕生、生存、過疎、過密処理
  DeadOrAlive( y, x ) {
    // (1) 周辺セル（８ヵ所）の座標生成
    let relative_position = [ [1,1], [1,0], [1,-1], [0,1], [0,-1], [-1,1], [-1,0], [-1,-1] ]

    let alive_cells_count = 0;
    // (2) 周辺の生きているセルのカウントアップ（マップ外は「死」扱い）
    for ( let [t,s] of relative_position ) {
      // ※但し、平坦トーラス面の場合は循環先のセル状態を考慮する
      alive_cells_count +=  Number( this.pattern?.[ y+t ]?.[ x+s ] || ( this.isTorus ? this.CallTorusProcessing( y+t, x+s ) : 0 ) );
    }
    // (3) 世代更新後の中心座標のセルの生死状態判定
    // ひとまず次世代では「死」と仮定
    let next_condition = 0;
    // 次世代で「生」になる可能性があるか判定
    if ( /0/.test( this.pattern[y][x] ) ) {
      // 元々死の状態だった場合 => 誕生するか判定
      if ( /3/.test( alive_cells_count ) ) { next_condition = 1; }
    } else {
      // 元々生の状態だった場合 => 生存するか判定
      if ( /2|3/.test( alive_cells_count ) ) { next_condition = 1; }
    }
    // 次世代での状態を返す => "0"or"1"
    return String( next_condition );
  }

  CallTorusProcessing( y, x ) {
    // y座標がマップ外の場合
    if ( y == -1 || y == this.height ) {
      // y座標の循環先へ
      y = ( y + this.height ) % this.height
    }
    // x座標がマップ外の場合
    if ( x == -1 || x == this.width ) {
      // x座標の循環先へ
      x = ( x + this.width ) % this.width
    }
    // 循環先の座標の状態を返す（ 0 or 1 ）
    return this.pattern[y][x];
  }
} // class
