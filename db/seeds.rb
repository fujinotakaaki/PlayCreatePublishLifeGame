# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# 管理者アカウントの作成
Admin.create(
  email: 'admin@user.com',
  password: 'password'
)

# 一般ユーザ第一号の作成
User.create(
  name: '藤野貴明',
  email: 'test@test.com',
  password: 'password',
  profile_image: File.open( './app/assets/images/myimage.png', ?r )
)
