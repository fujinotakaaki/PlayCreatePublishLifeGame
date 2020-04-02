
class LifeGame {
  // 中央座標から見て前後左右斜めの相対位置の組み合わせ（ムーア近傍）
  MOORE_NEIGHBORHOOD = [ [1,1], [1,0], [1,-1], [0,1], [0,-1], [-1,1], [-1,0], [-1,-1] ];
  // 世代更新回数
  generationCount = 0;
  // セルの表示設定
  alive = "■";
  dead = "□";


  // ===== ライフゲーム初期化処理 ==============================
  constructor( pattern = [ "0000", "0111", "1110", "0000" ], options = { isTorus: false } ) {
    // 世代更新回数
    // this.generationCount = 0;
    // 初期盤面の取得（要素がビット列の１次元配列）
    this.pattern = pattern;
    // 盤面の定義域取得
    [ this.height, this.width ] = [ pattern.length, pattern[0].length ];
    // セルの表示設定
    // [ this.alive, this.dead ] = [ "■", "□" ];
    // 平坦トーラス面フラグ（オプションが設定されている場合は反映）
    this.isTorus = options.isTorus;
    // リフレッシュメソッド用初期盤面の格納変数（浅いコピーだが、実装上不具合は見られない2020.03.21）
    this.patternInitial = pattern;
    // 中央座標から見て前後左右斜めの相対位置の組み合わせ（ムーア近傍）
    // this.mooreNeighborhood = [ [1,1], [1,0], [1,-1], [0,1], [0,-1], [-1,1], [-1,0], [-1,-1] ];
  }


  // ===== 盤面のHTMLテキストの出力メソッド ==============================
  get getPatternText() {
    // ビット列を表示形式に変換して返す（ 不具合①：this.alive = '0'だと正しく変換できない）
    return this.pattern.map( str => str.replace( /1/g, this.alive ).replace( /0/g, this.dead ) ).join( '<br>' );
  }


  // ===== 盤面のHTMLテキストの出力メソッド ==============================
  get patternRefresh() {
    // 初期世代の配置に置き換える（浅いコピーだが、実装上不具合は見られない2020.03.21）
    this.pattern = this.patternInitial;
    // 世代更新回数のリセット
    this.generationCount = 0;
  }


  // ===== セルの表示定義変更メソッド ==============================
  changeCellConditions( options = { alive: '■', dead: '□' }  ) {
    [ this.alive, this.dead ] = [ options.alive, options.dead ];
  }


  // ===== トーラス設定の切替メソッド ==============================
  changeTorusFlag( bool = 0 ) {
    this.isTorus = ( Number.isInteger( bool ) ? ! this.isTorus : !! bool )
    // 変更結果を返す
    return this.isTorus;
  }


  // ===== 世代交代処理 ==============================
  get generationChange() {
    // 世代更新後のパターン記憶変数
    let newPattern = new Array;
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
      newPattern.push( row );
    }
    // 次世代パターンを現在世代パターンに反映
    this.pattern = newPattern;
    // 世代更新回数のカウントアップ
    this.generationCount++;
  }


  // ===== 各セルの世代更新後の状態（誕生、生存、過疎、過密）決定処理 ==========
  deadOrAlive( y, x ) {
    // (1) 周辺の生きているセルのカウントアップ（マップ外は「死」扱い）
    let aliveCellsCount = 0;
    // ムーア近傍を調査（８箇所）
    for ( let [ t, s ] of this.MOORE_NEIGHBORHOOD ) {
      // 各座標の算出
      let [ b, a ] = [ y + t, x + s ];
      // 盤面内判定（ 0 <= y < this.height, 0 <= x < this.width ）
      if ( b + 1 && b - this.height && a + 1 && a - this.width ) {
        // 盤面内の場合
        aliveCellsCount += Number( this.pattern[b][a] );
      }else {
        // 盤面外の場合（※平坦トーラス面の場合は循環先のセルの状態を考慮する）
        aliveCellsCount += Number( this.isTorus ? this.pattern[ ( b + this.height ) % this.height ][ ( a + this.width ) % this.width ] : 0 );
      }
    }
    // ムーア近傍を調査（別案）
    // aliveCellsCount +=  Number( this.pattern?.[ y + t ]?.[ x + s ] || ( this.isTorus ? this.pattern[ ( y + t + this.height ) % this.height ][ ( x + s + this.width ) % this.width ] : 0 ) );

    // (2) 世代更新後の中心座標のセルの生死状態判定
    // ひとまず次世代では「死」と仮定
    let nextCondition = 0;
    // 次世代で「生」になる可能性があるか判定
    if ( /0/.test( this.pattern[y][x] ) ) {
      // 元々「死」の状態だった場合 => 誕生するか判定
      if ( /3/.test( aliveCellsCount ) ) { nextCondition = 1; }
    } else {
      // 元々「生」の状態だった場合 => 生存するか判定
      if ( /2|3/.test( aliveCellsCount ) ) { nextCondition = 1; }
    }
    // 次世代での状態を返す => "0" or "1"
    return String( nextCondition );
  }

  // ##### 追加機能 #########################
  // ===== 上下反転メソッド ==============================
  get flipVertical() {
    this.patternInitial = this.patternInitial.reverse()
  }

  // ===== 左右反転メソッド ==============================
  get flipHorizontal() {
    // 各行のビット列に対して処理実行
    this.patternInitial = this.patternInitial.map( bit_string =>
      // ビット列 => 配列 => （反転） => 文字列化
      bit_string.split('').reverse().join('')
    )
  }

  // ===== パターンの回転メソッド（反時計回りに90°回転） =====================
  get rotateCounterClockwise() {
    // 回転処理後のパターン記憶変数
    let newPattern = new Array;
    // 列後方からの処理
    for ( let x = this.width - 1; x >= 0; x-- ) {
      // 回転後の各行のビット列
      let row = new String;
      // 先頭行からの処理
      for ( let y = 0; y < this.height; y++ ) {
        // 行へビットの挿入
        row += this.patternInitial[y][x];
      }
      // パターン記憶変数に回転後のビット列を挿入
      newPattern.push( row );
    }
    // 初期盤面の更新
    this.patternInitial = newPattern;
    // 盤面の定義域変更
    [ this.height, this.width ] = [ this.width, this.height ];
  }
} // class
