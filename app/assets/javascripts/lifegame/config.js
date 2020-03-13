console.log('Read LifeGame_config.js');

// js版メインのライフゲームコード
class LifeGame {
  // デフォルトなんてない => グライダー銃になります
  constructor( options={ alive:'#', dead:'.' } ) {
    // 生きているセルのセルを数えるか
    this.alivecounting = options.alivecounting
    // コンソールにオプションの設定情報を表示
    console.log( 'options = ', options );
    // 生きたセルの表記
    if ( options.alive==undefined || options.alive.length!=1 ) {
      console.log( 'options.aliveに問題があります。 => ', options.alive );
      this.alive = '#';
    }
    else { this.alive = options.alive; } // options['alive']も表記としてOK
    // 死んだセルの表記
    if ( options.dead==undefined || options.dead.length!=1) {
      console.log( 'options.deadに問題があります。 => ', options.dead );
      this.dead = '.';
    }
    else { this.dead = options.dead; } // options['dead']も表記としてOK
    if ( this.alive==this.dead ) {
      this.alive='#';
      this.dead='.';
    }
    // # 現世代配列
    this.map = new Array;
    // # 新世代配列
    this.new_map = new Array;

    // 初期盤面ロード・格納
    this.map = new LifeGameMap( options );
    // 高さ決定
    this.height = this.map.length;
    // 幅決定
    this.width = this.map[0].length;
    // セル表示のフォーマットに変更がある場合、初期盤面にも適用する
    if ( this.alive!='#' || this.dead!='.' ) { this.ChangeInitialMap(); }
    // 生きているセルをカウントするため、正規表現の書式を作成
    this.myRe = new RegExp(this.alive, 'g');
    // 初期盤面の生きているセルのカウント
    this.CountingAliveCells();
    // マスの総数の桁数
    this.digits = Math.ceil( Math.log10( this.height ) + Math.log10( this.width ) );
  }

  // 盤面の更新と得取
  get UpDate() {
    this.GenerationChange();
  }

  // 盤面のHTML出力用盤面取得メソッド
  get GetMap() {
    return this.map.join( '<br>' );
  }

  // 現在の生きたセルの数を取得するメソッド
  get GetAliveCellsCount() {
    // 数える処理を実行
    this.CountingAliveCells();
    // 数え終えたら生きたセルの総数を返す
    return this.zeroPaddingAliveCells();
  }

  // private
  // # 世代交代操作
  GenerationChange() {
    // # 本処理
    // # マップ上部から開始(y=0)
    for ( let y = 0; y < this.height; y++ ) {
      var row = new String;
      // # マップ左から開始(x=0)
      for ( let x = 0; x < this.width; x++ ) {
        row = row.concat( this.DeadOrAlive( y, x ) );
      }
      // # 各行の操作が終了したら新世代配列に追加
      this.new_map.push( row );
    }
    // 新世代を現在世代に反映
    this.map = this.new_map;
    // # 新世代配列
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
    // # はみ出してたらfalseにしたい
    return (0<=y && y<this.height && 0<=x && x<this.width);
  }

  // 初期盤面の書式変換
  ChangeInitialMap() {
    console.log( 'Rebuilding map' );
    // 盤面更新後の格納変数
    var apply_format_map = new Array;
    // 更新前の盤面の各行
    var row1 = new Array;
    // 更新前の盤面の各行を配列にsplitしたもの
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

  // 盤面の生きているセルの親カウントメソッド（生きたセルの総数の初期化と盤面から各行を取得する）
  CountingAliveCells() {
    // 生きているセルのカウント数の初期化
    this.alive_count = 0;
    // 各行の取得とカウントアップ処理
    this.map.forEach( row => this.subCountingt(row));
  }

  // 盤面の生きているセルの子カウントメソッド（取得した行の生きたセルを数える）
  subCountingt( row ) {
      // console.log(row);
      // 正規表現にマッチするものを全部抽出 => 配列化 => 配列の要素数取得
      var count = ( row.match( this.myRe ) || [] ).length ;
      // console.log(': count=',count,'<br>')
      // 生きているセルのカウントアップ
      this.alive_count += count
  }

  // 生きているセルの数を0埋めして出力
  zeroPaddingAliveCells(){
    return ( '00000' + this.alive_count ).slice( -this.digits );
  }
} // class
