/*
* =============================
* ライフゲームのシステム部
* =============================
* # => 内部操作
* @ => 外部操作
*/
class LifeGame {
  /* =============================
  # 定数など
  ============================= */
  // 中央座標から見て前後左右斜めの相対位置の組み合わせ（ムーア近傍）
  MOORE_NEIGHBORHOOD = [ [1,1], [1,0], [1,-1], [0,1], [0,-1], [-1,1], [-1,0], [-1,-1] ];
  // 世代更新回数
  generationCount = 0;
  // セルの表示設定
  alive = "■";
  dead = "□";
  // 平坦トーラス面フラグ（オプションが設定されている場合は反映）
  isTorus = false;

  /* =============================
  # ライフゲーム初期化処理
  ============================= */
  constructor( pattern = [ "0000", "0111", "1110", "0000" ] ) {
    // 初期盤面の取得（要素がビット列の１次元配列）
    this.pattern = pattern;
    // 盤面の定義域取得
    [ this.height, this.width ] = [ pattern.length, pattern[0].length ];
    // リフレッシュ処理用初期盤面の格納変数（浅いコピーだが、実装上不具合は見られない2020.03.21）
    this.patternInitial = pattern;
  }


  /* =============================
  @ 盤面のHTMLテキストの出力処理
  ============================= */
  get getPatternText() {
    // ビット列をセルの表示形式に変換して返す（ 不具合①：this.alive = '0'だと正しく変換できない）
    return this.pattern.map( str => str.replace( /1/g, this.alive ).replace( /0/g, this.dead ) ).join( '<br>' );
  }


  /* =============================
  @ 盤面のHTMLテキストの出力処理（上の処理と同じ、統合したいがわからない）
  ============================= */
  static convertPatternText( patternArray ) {
    // ビット列をセルの表示形式に変換して返す
    return patternArray.map( str => str.replace( /1/g, "■" ).replace( /0/g, "□" ) ).join( '<br>' );
  }


  /* =============================
  @ 盤面の初期化処理
  ============================= */
  get patternRefresh() {
    // 初期世代の配置に置き換える（浅いコピーだが、実装上不具合は見られない2020.03.21）
    this.pattern = this.patternInitial;
    // 世代更新回数のリセット
    this.generationCount = 0;
    // coupler位置の初期化
    [ this.rowIndex, this.columnIndex ] = [ 0, 0 ];
  }


  /* =============================
  @ セルの表示定義変更処理
  ============================= */
  changeCellConditions( options = { alive: '■', dead: '□' }  ) {
    [ this.alive, this.dead ] = [ options.alive, options.dead ];
  }


  /* =============================
  @ トーラス設定の切替処理
  ============================= */
  changeTorusFlag( bool = 0 ) {
    this.isTorus = ( Number.isInteger( bool ) ? ! this.isTorus : !! bool );
    // 変更結果を返す
    return this.isTorus;
  }


  /* =============================
  @ 世代交代処理
  ============================= */
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
  /*
  === Promiseによる行毎の非同期処理導入 ===
  結果: 改善効果なし
  考察: Promiseで処理の分割が可能になるが、
  全ての処理が同じthis.pattern変数へアクセスが集中する。
  よって、このアクセスが直列的な処理となるため、
  非同期処理の効果がないものと考えられる。
  また、上記変数アクセス以外の処理で
  律速段階となるような思い処理がないことからも
  この考察を示唆するものと考えられる。

  もし、期待通りの並列処理がいくのであれば、
  245個の並列処理が行われるので、
  理論値: 27.806ms / 245 = 0.113ms
  となるはず。 （並列化への実行処理、並列でない部分の処理、245個も同時に計算できる？のため実際は理論値程速くはならない）

  パターンサイズ: 245x300 ( height x width )
  Promise | 試行回数 | 平均 [ms/世代更新]
  未使用    | 191         | 27.806
  使用　    | 133         | 26.684
  */


  /* =============================
  # 各セルの世代更新後の状態（誕生、生存、過疎、過密）決定処理
  ============================= */
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
      if ( /3/.test( aliveCellsCount ) ) nextCondition = 1;
    } else {
      // 元々「生」の状態だった場合 => 生存するか判定
      if ( /2|3/.test( aliveCellsCount ) ) nextCondition = 1;
    }
    // 次世代での状態を返す => "0" or "1"
    return String( nextCondition );
  }


  /* =============================
  @ 上下反転処理
  ============================= */
  get flipVertical() {
    this.patternInitial = this.patternInitial.reverse();
    // 盤面の初期化
    this.patternRefresh;
  }


  /* =============================
  @ 左右反転処理
  ============================= */
  get flipHorizontal() {
    // 各行のビット列に対して処理実行
    this.patternInitial = this.patternInitial.map( bit_string =>
      // ビット列 => 配列 => （反転） => 文字列化
      bit_string.split('').reverse().join('')
    )
    // 盤面の初期化
    this.patternRefresh;
  }


  /* =============================
  @ パターンの回転処理（反時計回りに90°回転）
  ============================= */
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
    // 盤面の初期化
    this.patternRefresh;
  }



  /* =============================
  # パターンの合成用管理変数
  ============================= */
  // couplerの行数
  rowIndex = 0;
  // couplerの列数
  columnIndex = 0;
  // 合成可能判定の初期化
  coupleable = false;


  /* =============================
  @ couplerの入力処理
  ============================= */
  setCoupler(coupler) {
    // couplerのオブジェクト作成
    this.coupler = new LifeGame(coupler);
    // couplerが母体のサイズを超えていないか判定
    this.coupleable = this.height >= this.coupler.height && this.width >= this.coupler.width;
    // couplerが母体のサイズよりも大きいパターンの場合
    if ( ! this.coupleable ) {
      // 設定の失敗通知
      console.error("合成するパターンが大き過ぎます");
    }
    // 設定の結果を返す
    return this.coupleable;
  }

  /* =============================
  @ coupler回転処理
  ============================= */
  get couplerRotate() {
    if ( ! this.coupleable ) return false;
    // 回転可能なサイズか判定
    let rotateable = this.height >= this.coupler.width && this.width >= this.coupler.height;
    // 判定結果を返す
    if ( ! rotateable ) return false;
    // couplerを反時計回りに90°回転
    this.coupler.rotateCounterClockwise;
    // 回転した際にはみ出す場合は、はみ出ない位置まで移動
    if ( this.coupler.height + this.rowIndex > this.height ) this.rowIndex = this.height - this.coupler.height;
    if ( this.coupler.width + this.columnIndex > this.width ) this.columnIndex = this.width - this.coupler.width;
    // 判定結果を返す
    return true;
  }


  /* =============================
  @ coupler位置移動処理
  ============================= */
  moveCouplerPosition( move = [0,0], skipLength = 1 ) {
    if ( ! this.coupleable ) return false;
    let [ y, x ] = [ this.rowIndex + move[0] * skipLength, this.columnIndex + move[1] * skipLength ];
    if ( 0 <= y && y < this.height - this.coupler.height + 1 ) this.rowIndex = y;
    if ( 0 <= x && x < this.width - this.coupler.width + 1 ) this.columnIndex = x;
  }


  /* =============================
  @ 合成状態の盤面プレビュー取得処理
  ============================= */
  couplingPreview( action = { finishCoupling: false } ) {
    if ( ! this.coupleable ) return false;
    let [ yd, xd ] = [ this.rowIndex, this.columnIndex ];
    let [ yu, xu ] = [ yd + this.coupler.height, xd + this.coupler.width ];
    let result = this.patternInitial;
    result = result.map( function(bitString,idx) {
      if ( yd <= idx && idx < yu) {
        let couplerSection  = action.finishCoupling ? this[idx-yd] : `<span style="color: magenta;">${this[idx-yd]}</span>`;
        return bitString.slice(0,xd) + `${couplerSection}` + bitString.slice(xu);
      }
      return bitString;
    }, this.coupler.patternInitial );
    if ( action.finishCoupling ) {
      // 初期盤面の更新
      this.patternInitial = result;
      // 盤面の初期化
      this.patternRefresh;
    }
    return result.map( str => str.replace( /1/g, this.alive ).replace( /0/g, this.dead ) ).join( '<br>' );
  }
} // class
