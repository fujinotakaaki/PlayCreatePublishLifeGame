require 'rails_helper'
# bundle exec rspec spec/features/devise_spec.rb
RSpec.feature 'ユーザー認証に関するテスト１' do
  let!(:user){build(:user, confirmed_at: nil)}
  let!(:uniq_user){create(:user)}
  after do
    ActionMailer::Base.deliveries.clear
  end

  # アカウント有効化のリンク取得メソッド
  def extract_confirmation_url(email)
    body = email.body.encoded
    # メール内のリンクは１つしかないため問題なし
    body[/http[^"]+/]
  end

  scenario '新規登録 => ログイン => ログアウトに成功' do
    # 1) ログインの失敗
    # ログインページへ遷移
    visit new_user_session_path
    # フォームに値を入力
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
    # ログイン失敗によるエラーメッセージを確認
    expect(page).to have_text('Eメールまたはパスワードが違います')

    # 2) アカウントの新規登録の成功
    # アカウントの新規登録ページへ遷移
    visit new_user_registration_path
    # フォームに値を入力
    fill_in 'user[name]', with: user.name
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    fill_in 'user[password_confirmation]', with: user.password
    # アカウントの新規登録実行
    expect { click_button 'アカウント作成' }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    # 認証メールを送信したことの通知確認
    expect(page).to have_text('本人確認用のメールを送信しました')
    expect(page).to have_text('アカウントを有効化させてください')

    # 3) アカウント有効化前によるログインの失敗
    # ログインページへ遷移
    visit new_user_session_path
    # フォームに値を入力
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
    # ログイン失敗によるエラーメッセージを確認
    expect(page).to have_text('メールアドレスの本人確認が必要です')

    # 4) アカウントの有効化に成功
    # 認証メールからアカウントを有効化する
    activate_email = ActionMailer::Base.deliveries.last
    activate_url = extract_confirmation_url(activate_email)
    visit activate_url

    # 5) アカウント有効化後によるログインの成功の確認
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
    # ログイン成功の通知確認
    expect(page).to have_text('ログインしました')

    # 6) ログアウトの実行
    visit root_path
    click_link 'ログアウト' # 本来は非表示
    # ログイン成功の通知確認
    expect(page).to have_text('ログアウトしました')
  end # scenario '新規登録 => ログイン => ログアウトのテスト'


  # 新規登録失敗テストの共通操作
  def sign_up_test(error_message, **options)
    # アカウントの新規登録ページへ遷移
    visit new_user_registration_path
    # 入力用のデータを作成
    test_user = build(:user, confirmed_at: nil)

    # フォームに値を入力
    fill_in 'user[name]', with: options[:name] || test_user.name
    fill_in 'user[email]', with: options[:email] || test_user.email
    fill_in 'user[password]', with: options[:password] || test_user.password
    fill_in 'user[password_confirmation]', with: options[:password_confirmation] || options[:password] || test_user.password

    # レコードが作成されていないことを確認
    expect { click_button 'アカウント作成' }.to_not change { User.count }
    # エラーメッセージ存在の確認
    expect(page).to have_text(error_message)
  end

  feature '入力項目の不備による新規登録の失敗' do
    scenario '名前が空欄は無効' do
      sign_up_test('ユーザ名を入力してください', name: "")
    end

    scenario 'Eメールが空欄は無効' do
      sign_up_test('Eメールを入力してください', email: "")
    end

    scenario '登録済のEメールは無効' do
      sign_up_test('Eメールはすでに存在します', email: uniq_user.email)
    end

    scenario 'パスワードが6文字未満は無効' do
      shorter_password = SecureRandom.alphanumeric(1+rand(5))
      sign_up_test('パスワードは6文字以上で入力してください', password: shorter_password)
    end

    scenario '再入力パスワードが異なる場合は無効' do
      mis_spell_password = SecureRandom.alphanumeric
      sign_up_test('パスワード（確認用）とパスワードの入力が一致しません', password_confirmation: mis_spell_password)
    end
  end # context '新規登録失敗のテスト'
end # feature 'ユーザー認証に関するテスト１'


RSpec.feature "ユーザー認証に関するテスト２", js: true do
  let!(:user){create(:user)}

  scenario 'アカウントの削除に成功' do
    # 1) ログイン手続き
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'

    # 2) トップからマイページへの移動手続き
    visit root_path
    # ドロップダウンメニューの捕捉
    dropdown_menu_ul = find(:css, '.application__header--dropdownMenue', visible: false)
    # ドロップダウンメニューの出現の確認
    expect do
      # ヘッダーのプロフィールのイベントを発火
      find(:css, '.application__header--interface').all('li')[-1].hover
    end.to change{dropdown_menu_ul.visible?}.from(be_falsey).to(be_truthy)
    # ドロップダウンメニュー内のボタンからマイページへ遷移
    dropdown_menu_ul.all('li')[1].find_link('マイページ').click

    # 3) 退会ページへの移動手続き
    expect(current_path).to eq member_path(id: user, locale: I18n.default_locale)
    # 編集ボタン押下により、退会ページへのアクセスボタンを呼び出す
    click_link '編集'
    # 退会ページへのアクセス
    click_link '退会する'

    # 4) 退会ページでの退会手続き
    modal_css = '.members__modal'
    # モーダルウィンドウの捕捉
    modal_div = find(:css, modal_css, visible: false)
    # 退会するボタン押下でモーダルウィンドウ出現の確認
    expect do
      click_link '退会する'
    end.to change{modal_div.visible?}.from(be_falsey).to(be_truthy)
    # モーダルウィンドウ内に限定
    within(:css, modal_css) do
      # 退会ボタンの捕捉
      withdraw_button = find("input[type=submit]")
      # モックアップ上の入力フォームに、退会用文字列の記入
      expect do
        fill_in 'confirm_member', with: user.confirm_text
      end.to change{withdraw_button.disabled?}.from(be_truthy).to(be_falsey)
      # 退会ボタン押下によるリクエストでアカウントが削除されたことを確認
      expect do
        withdraw_button.click
      end.to change(User, :count).by(-1)
    end

    # 5) アカウント削除の通知確認
    expect(page).to have_text('アカウントを削除しました')
  end # scenario 'アカウントの削除に成功'
end # feature "ユーザー認証に関するテスト２"
