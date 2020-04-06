// ===== Cropperjs処理関連 ===============
$( function() {
  // リロード促進メッセージの削除
  $(".makings__new--caution").text("");
  // アップロードボタンの表示
  $(".makings__new--sectionA").css({"display": "block"});
  // プレビュー見出しの表示
  $(".makings__new--headline").css({"display": "block"});

  var fileName;
  // ===== 画像ファイルアップロード時の処理 ===============
  $("#crop_image").on( 'change', function(event) {
    // アップロードしたファイルの取得
    let file = event.target.files[0];
    // 画像ファイル以外の場合は何もしない
    if ( file.type.indexOf('image') < 0 ) { return false; }
    // ファイル名取得
    fileName = file.name;
    let reader = new FileReader();
    // ファイル読み込みが完了した際のイベント登録
    reader.onload = ( function(file) {
      return function(event) {
        // クロッピングする画像の<img>タグ生成
        let currentCroppingImage = $('<img>').attr({
          src: event.target.result,
          id: "crop_image",
          title: fileName
        });
        $('#crop_area_box').html( currentCroppingImage );
        // 初期設定
        initCrop();
      };
    })(file);
    reader.readAsDataURL(file);
    $(".makings__new--changeButton").fadeIn();
  });

// ===== 画像２値化処理じっこう ===============
  $("#binarize_threshold").on( 'change', function() {
    imageBinarization();
  });
});

var cropper;
// ===== Cropperjs初期設定 ====================
function initCrop() {
  // オプションの定義
  let options = {
    // 画像の移動の許可
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
  cropper = new Cropper( crop_image, options );
  // 各処理時のプレビュー反映効果付与
  // 初期表示
  $("#crop_image").on( 'ready', () => cropPreviewDraw() );
  // 画像をドラッグ時
  $("#crop_image").on( 'cropend', () => cropPreviewDraw() );
  // 画像を拡大・縮小時
  $("#crop_image").on( 'zoom', () => cropPreviewDraw() );
}

// ===== プレビュー反映処理 ===============
function cropPreviewDraw() {
  // キャンバスサイズの設定
  let croppedCanvas = cropper.getCroppedCanvas({
  maxWidth: 150,
    maxHeight: 150
  });
  // クロップ処理後の画像の<img>タグ生成
  let croppedImage = $('<img>').attr({
    src: croppedCanvas.toDataURL()
  });
  // クロップ画像の<img>タグ挿入（上書き）
  $("#crop_preview").html(croppedImage);
}

// ===== 処理移行モード（画像２値化） ===============
function changeBinarizationMode(self) {
  $(".makings__new--sectionA h3").hide();
  self.remove();
  $(".makings__new--sectionA").animate( { width: 'hide' }, 'slow', function() {
    $(".makings__new--sectionC").fadeIn('slow');
  });
  imageBinarization();
}

var dst;
// ===== 画像２値化処理 ===============
function imageBinarization() {
  let threshold = Number( $("#binarize_threshold").val() );
  let cvs = document.getElementById("crop_preview_binarization");
  let ctx = cvs.getContext("2d");
  let croppedImage = $("#crop_preview").find("img");
  let [ cw, ch ] = [ croppedImage.width(), croppedImage.height() ];
  let img = new Image();
  img.src = croppedImage.attr("src");
  img.onload = function() {
    ctx.drawImage( img, 0, 0 );
    let src = ctx.getImageData( 0, 0, cw, ch );
    dst = ctx.createImageData( cw, ch );
    let len = src.data.length;
    for (let i = 0; i < len; i += 4) {
      let y = 0 | ( 0.299 * src.data[i] + 0.587 * src.data[i + 1] + 0.114 * src.data[i + 2] );
      let ret = ( y < threshold ) ? 0 : 255;
      dst.data[i] = dst.data[i+1] = dst.data[i+2] = ret;
      dst.data[i+3] = 255;
    }
    ctx.putImageData(dst, 0, 0);
  }
}

function convertCanvasToMakingPattern(self) {
  let [ cw, ch ] = [ dst.width, dst.height ];
  // キャンバスのピクセルデータを白黒1bitの情報に削る
  let arr = dst.data.filter( ( luminance, idx ) => idx % 4 == 0 );
  // パターンデータに変換できるようテキストデータに落とし込む
  let binarizedImageBitStrings = arr.reduce( function( accumulator, currentLuminance, currentIndex ) {
    if ( currentIndex % cw == 0 ) {
      accumulator += ( currentIndex == 0 ? "" : "," );
    }
    accumulator += ( currentLuminance == 0 ? "0" : "1" );
    return accumulator;
  }, "" );
  $("#making_making_text").val(binarizedImageBitStrings);
  $(self).closest("form").submit();
}
