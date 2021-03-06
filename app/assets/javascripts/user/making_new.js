// （グローバル変数3）
var cropper;

/*
* =============================
* Cropperjs初期設定
* =============================
*/
function startUpCropping(self) {
  // ===== Cropperjs開始時処理 ===============
  function main(self) {
    // アップロードしたファイルが画像か結果を受け取る（user.js）
    let result = validateImageFile( self, finishOnLoad );
    // 画像でない場合は処理中止
    if ( ! result ) return;

    // クロッピング作業完了用ボタン表示
    $(".makings__new--changeButton").fadeIn();
    // 手順表示の切り替え
    $(".makings__new--infoH3").fadeOut(function(){
      $(this).text("手順２：画像のトリミング").fadeIn();
      $(".makings__new--infoH6").text("トリミング画像は縦横最大300pxまでになります。");
    })
  }

  // ===== 画像の読み込みが完了した際の処理、クロッピング画像の挿入 ===============
  const finishOnLoad = function( element, srcData ) {
    // アップロード画像の<img>タグ生成
    let currentCroppingImage = $('<img>').attr({
      "src": srcData,
      "id": "crop_image"
    });
    // アップロード画像の挿入
    $('#crop_area_box').html( currentCroppingImage );

    // Cropperオプションの設定
    let options = {
      viewMode: 1,
      // 画像の移動を許可
      dragMode: 'move',
      // ガイド線非表示
      guides: false,
      // トリミング枠のトぐるドラッグリサイズ
      toggleDragModeOnDblclick: false,
      // 回転操作
      rotatable: false,
      // 最小高さ
      minCropBoxHeight: 10,
      // 最小幅
      minCropBoxWidth: 10
    };
    // Cropperオブジェクト生成
    cropper = new Cropper( crop_image, options );
    // 各処理時のプレビュー反映効果付与
    $("#crop_image").on({
      // 初期表示
      ready: () => cropPreviewDraw(),
      // 画像をドラッグ時
      cropend: () => cropPreviewDraw(),
      // 画像を拡大・縮小時
      zoom: () => cropPreviewDraw()
    });
  };

  // ===== プレビュー反映処理 ===============
  const cropPreviewDraw = function() {
    // クロッピング画像の取得
    let croppedCanvas = cropper.getCroppedCanvas();
    // クロップ処理後の画像の<img>タグ生成
    let croppedImage = $('<img>').attr({
      src: croppedCanvas.toDataURL()
    });
    // クロップ画像の<img>タグ挿入（上書き）
    $("#crop_preview").html(croppedImage);
  }

  main(self);
}


/*
* =============================
* 処理移行モード（画像２値化）
* =============================
*/
function changeBinarizationMode(self) {
  // 元画像を表示しているセクションの画像位以外の要素を非表示にする
  $(".makings__new--sectionA h3").hide();
  self.remove();
  // 手順表示の切り替え
  $(".makings__new--infoH3").fadeOut(function(){
    $(this).text("手順３：画像の２値化").fadeIn();
    $(".makings__new--infoH6").text("本処理が終了すればパターンとして一時保存されます。");
  });
  // 元画像を表示しているセクションを非表示にする
  $(".makings__new--sectionA").animate( { width: 'hide' }, 'slow', function() {
    // 画像の２値化処理画面表示
    $(".makings__new--sectionC").fadeIn('slow');
  });
  // 画像の２値化実行
  imageBinarization('auto')
}


/*
* =============================
* 画像２値化処理
* =============================
*/
function imageBinarization( threshold = 'auto' ) {
  // ===== 本処理 ====================
  function main( threshold ) {
    // クロッピング画像のimg要素取得
    let croppedImage = $("#crop_preview").find("img").get(0);
    // 新規canvas要素生成（画像の伸縮がこの作成方法で防げる）
    let sizeSetting = {
      'width': croppedImage.width,
      'height': croppedImage.height
    }
    let newCanvas = $('<canvas/>', { 'id': 'crop_preview_binarization' } ).attr( sizeSetting ).get(0);
    // Draw (Resize)
    let ctx = newCanvas.getContext('2d');
    ctx.drawImage(croppedImage, 0, 0, croppedImage.width, croppedImage.height);
    // Uint8ClampedArrayを取得
    let dst = ctx.getImageData( 0, 0, croppedImage.width, croppedImage.height );
    // 閾値の設定（'auto': 判別分析法から決定 or 入力フォームの値から）
    threshold = ( threshold == 'auto' ? thresholdOtsu( croppedImage ) : threshold | 0 );
    // 入力フォームへ値の上書き
    $("#threshold_form").val( threshold );
    // 画像２値化処理
    for ( let i = 0; i < dst.data.length; i += 4 ) {
      let y = grayscale( dst.data[i], dst.data[i + 1], dst.data[i + 2] );
      let lightness = ( y < threshold ) ? 0 : 255;
      dst.data[i] = dst.data[i+1] = dst.data[i+2] = lightness;
      dst.data[i+3] = 255; // 不透明にする
    }
    // ２値化画像反映
    ctx.putImageData(dst, 0, 0);
    // ページ上の２値化画像更新
    $("#crop_preview_binarization").replaceWith( newCanvas );
  }

  /*
  * =============================
  * 判別分析法（大津の2値化）による閾値の決定メソッド
  * =============================
  */
  function thresholdOtsu( image ) {
    // ===== 判別分析法の本処理 ===============
    function search( image ) {
      let cvs = $('<canvas/>').attr('width', image.width).attr('height', image.height).get(0);
      // キャンパス要素から二次元グラフィックスのコンテキストを取得
      let ctx = cvs.getContext("2d");
      // 読み込んだ画像を描画
      ctx.drawImage(image, 0, 0, image.width, image.height);
      // 画像のUint8ClampedArrayを取得
      let src = ctx.getImageData(0, 0, image.width, image.height);

      // 総画素数
      let w = src.data.length / 4;
      // 輝度総和
      let s = 0;
      // 画像の輝度に関する度数分布表作成
      let histgram = Array(256).fill(0);
      for (let i = 0; i < w; i++) {
        let gs = grayscale( src.data[ 4*i ], src.data[ 4*i+1 ], src.data[ 4*i+2 ] );
        s += gs;
        histgram[gs]++;
      }

      // 閾値とクラス間分散の最大値
      let [ threshold, maxBetweenClassVariance ] = [ 0, 0 ];
      // クラス間分散の最大値の探索
      for ( let i = 0; i < 256; i++ ) {
        let current = calculateBetweenClassVariance( i, w, s, histgram );
        if ( maxBetweenClassVariance < current ) {
          maxBetweenClassVariance = current;
          threshold = i;
        }
      }

      // 得られた閾値を返す
      return threshold;
    }

    // ===== クラス間分散の計算 ===============
    function calculateBetweenClassVariance( i, w, s, histgram ) {
      // クラス0の度数と輝度総和を計算
      let [ w1, sum1 ] = histgram.reduce( function( acc, val, idx ) {
        if ( i > idx ) {
          acc[0] += val;
          acc[1] += val * idx;
        }
        return acc;
      }, [ 0, 0 ] );

      // 1クラスの度数と輝度総和を計算
      let [ w2, sum2 ] = [ w - w1, s - sum1 ];

      // 各クラスの輝度平均値を計算
      let m1 = w1==0 ? 0 : sum1 / w1;
      let m2 = w2==0 ? 0 : sum2 / w2;

      // クラス間分散を計算して返す
      return w1 * w2 * (m1 - m2)**2;
    }

    return search( image );
  }

  // グレースケール変換式の定義（0.5000は四捨五入を考慮）
  // const grayscale = (r, g, b) => 0.2126 * r + 0.7152 * g + 0.0722 * b
  const grayscale = (r, g, b) => ( 0.500 + 0.299 * r + 0.587 * g + 0.114 * b ) | 0;

  main( threshold );
}


/*
* =============================
* submitボタン押下時の処理
* =============================
*/
function convertCanvasToMakingPattern() {
  // 「生」セルの領域の輝度取得
  let alive = $("#cells_condition_form").val();
  // canvas要素取得
  let cvs = $("#crop_preview_binarization").get(0);
  // canvas寸法取得
  let [ cw, ch ] = [ cvs.width, cvs.height ];
  // canvas要素のコンテキスト取得
  let ctx = cvs.getContext("2d");
  // Uint8ClampedArrayを取得
  let dst = ctx.getImageData( 0, 0, cw, ch );
  // canvasの各ピクセルの輝度情報のみに削る
  let arr = dst.data.filter( ( luminance, idx ) => idx % 4 == 0 );
  // パターンデータに変換できるようテキストデータに落とし込む
  let binarizedImageBitStrings = arr.reduce( function( accumulator, currentLuminance, currentIndex ) {
    if ( currentIndex % cw == 0 ) {
      // 行の前後の区切りを挿入
      accumulator += ( currentIndex == 0 ? "" : "," );
    }
    // 輝度をセルに変換
    accumulator += ( currentLuminance == alive ? "1" : "0" );
    return accumulator;
  }, "");
  // フォームに値を挿入
  $("#making_making_text").val(binarizedImageBitStrings);
  // 送信の許可
  return true;
}
