# coding: utf-8
require 'csv'

# ====================
# 管理者アカウントの作成
# ====================
Admin.create(
  email: ENV['ADMIN_EMAIL'] || "lifegame@admin.com",
  password: ENV['ADMIN_PASSWORD'] || "lifegame"
)


# ====================
# 一般ユーザの作成
# ====================
MESSAGE = <<-'CONTENT'
Play!Create!Publish! LifeGameのユーザ第１号です。
本コンテンツは「ゲーム」と言いつつ、「テレビゲーム」や「スマホゲーム」とは大きく異なり、
現代の娯楽とは無縁そうなコンテンツになります。
上記のように、「ライフゲーム」は生物のライフサイクルをシミュレーションしようという試みを具現化したもののひとつです。
先人たちの多くの研究により、パターンと呼ばれるものが発見され、それらを組み合わせることで非常に興味深い変化を示すものが多数存在します。
ライフゲームは、生きているセル（以下「セル」）を無作為に配置すると、一定期間その変化が楽しめますが、おおよそはわずかな固定物体や小さな振動子だけが残ります。
では、「ずっと変化が楽しめるパターンはあるのか？」、「セルは無限に増えないか？」、「このコンテンツを研究して何ができるのか？」と思っていただけたのであれば、
是非とも本サイトに目を通していただければと思います。また、パターンを自作する機能も備えておりますので、是非ご活用くださいませ。
CONTENT

users = []

users << User.new(
  # id: 1
  name: '藤野貴明',
  email: ENV['USER_EMAIL'] || 'lifegame@user.com',
  password: ENV['USER_PASSWORD'] || 'password',
  introduction: MESSAGE,
  profile_image: File.open( './app/assets/images/myimage.png', ?r )
)
users << User.new(
  # id: 2
  name: 'テストユーザ',
  email: 'lifegame@sakura.com',
  password: 'password',
  introduction: "コメント、お気に入り登録役",
  profile_image: File.open( './app/assets/images/myimage.png', ?r )
)
users.map do |user|
  user.skip_confirmation!
  user.save!
  break if Rails.env.production?
end


# ====================
# ジャンルの作成
# ====================
Category.create(
  # id: 1
  name: '未分類',
  explanation: '未分類の項目'
)
Category.create(
  # id: 2
  name: '固定物体',
  explanation: '世代が進んでも同じ状態を保つ物体.'
)
Category.create(
  # id: 3
  name: '振動子',
  explanation: '１より大きい周期で元の状態に戻る物体.'
)
Category.create(
  # id: 4
  name: '移動物体',
  explanation: '形を変えずに移動する物体のこと。振動子の一部と考えられるが、元の位置から動くもの.'
)
Category.create(
  # id: 5
  name: '繁殖型',
  explanation: 'セルが無限にあれば無限に増え続ける物体.'
)
Category.create(
  # id: 6
  name: '長寿型',
  explanation: '長い世代にわたって不規則な変化を続ける物体の総称.'
)
Category.create(
  # id: 7
  name: 'エデンの園配置',
  explanation: 'いかなる配置からも到達できない配置.'
)
Category.create(
  # id: 8
  name: '合成',
  explanation: 'パターン同士の衝突により発生するする配置など.'
)
Category.create(
  # id: 9
  name: '観賞',
  explanation: 'ライフゲーム の挙動を楽しむことが目的.'
)
Category.create(
  # id: 10
  name: '変化',
  explanation: '特殊な挙動を示す配置など.'
)


# ====================
# 表示形式デフォルトの作成
# ====================
DisplayFormat.create(
  # id: 1
  user_id: 1,
  name: 'Default 1',
  alive: '■',
  dead: '□',
  font_size: 40,
  line_height_rate: 53,
  letter_spacing: -3,
)
DisplayFormat.create(
  # id: 2
  user_id: 1,
  alive: '■',
  dead: '□',
  name: 'Big Pattern',
  font_size: 10,
  line_height_rate: 45,
  letter_spacing: -2,
)
DisplayFormat.create(
  # id: 3
  user_id: 1,
  name: 'Default 2',
  alive: '草',
  dead: '　',
  font_size: 25,
  line_height_rate: 100,
  letter_spacing: 0,
)
DisplayFormat.create(
  # id: 4
  user_id: 1,
  name: 'Default 3',
  alive: '生',
  dead: '　',
  font_color: '#228B22',
  background_color: '#ADFF2F',
  font_size: 35,
  line_height_rate: 92,
  letter_spacing: -3,
)

sample = "c000000000,4000300000,5000300000,3000000000,0,0,600000000,9000c0000,600080000,80040,400a0,a0,40,0,0,0,0,0,0,240,1c0,30000000003,30000000003,e00000000,900000000,0,0,0,0,0,0,800000000,1400000000,1400800000,800400000,400180,c00240,180,0,0,0,300000,300000"
Making.create(
  user_id: 1,
  margin_top: 1,
  margin_bottom: 2,
  margin_left: 3,
  margin_right: 3,
  normalized_rows_sequence: sample,
)

CSV.foreach( 'db/pattern_library.csv', headers: true ) do |row|
Pattern.create(
  user_id: row[0],
  category_id: row[1],
  display_format_id: row[2],
  name: row[3],
  introduction: row[4],
  margin_top: row[5],
  margin_bottom: row[6],
  margin_left: row[7],
  margin_right: row[8],
  normalized_rows_sequence: row[9],
  is_torus: row[10]
)
end


# 各パターンについて、お気に入り登録とコメント投稿をが２件ずつある
comments_arr = %w(
  綺麗だなぁ。
  面白い動きをしますね。
  シンプルですね！！
  このパターンってそんな名前だったんですね。初めて知りました。
  これよく見るやつだ！
  先に作られてしまいましたか。
  Foo↑おもしろいっすね！
  草生える
  もっといっぱいパターン作ってください！お願いします！！
  次回作期待してます！
  お、おう。。。
)

# 全パターンに対してお気に入り登録andコメント登録
Pattern.all.pluck(:id).each do | pattern_id |
  break if Rails.env.production?
  # お気に入り登録
  if rand(10) > 4 then
    Favorite.create(
      user_id: [1,2,2,2].sample,
      pattern_id: pattern_id
    )
  end

  # コメント投稿
  rand(6).times do | i |
    PostComment.create(
      user_id: [1,2,2,2,2].sample,
      pattern_id: pattern_id,
      body: comments_arr.sample
    )
  end
end
