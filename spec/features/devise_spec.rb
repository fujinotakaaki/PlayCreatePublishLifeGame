require 'rails_helper'
RSpec.feature 'ユーザー認証に関するテスト' do
  after do
    ActionMailer::Base.deliveries.clear
  end

  # アカウント有効化のリンク取得メソッド
  def extract_confirmation_url(email)
    body = email.body.encoded
    # メール内のリンクは１つしかないため問題なし
    body[/http[^"]+/]
  end

  LOCALE_JA = { locale: :ja }
  let(:user){build(:user, confirmed_at: nil)}


  scenario '新規登録 => ログイン => ログアウトのテスト' do
    # 1) ログインの失敗の確認
    # ログインページへ遷移
    visit new_user_session_path(LOCALE_JA)
    # フォームに値を入力
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    # ログイン失敗によりページ遷移がしないことを確認
    expect{click_button 'ログイン'}.to_not change{ current_path }
    # エラーメッセージを確認
    expect(page).to have_text('Eメールまたはパスワードが違います')

    # 2) アカウントの新規登録
    # アカウントの新規登録ページへ遷移
    visit new_user_registration_path(LOCALE_JA)
    # フォームに値を入力
    fill_in 'user[name]', with: user.name
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    fill_in 'user[password_confirmation]', with: user.password
    # アカウントの新規登録実行
    expect { click_button 'アカウント作成' }.to change { ActionMailer::Base.deliveries.size }.by(1)

    # 3) 新規登録処理の実行確認
    # トップページに遷移（される）を確認
    expect(current_path).to eq root_path(LOCALE_JA)
    # 指定したセレクタ内に対してのみ検索/操作が行われる
    flsh_css = '.application__flash'
    within(:css, flsh_css) do
      # 認証メールを送信したことの通知確認
      expect(page).to have_text('本人確認用のメールを送信しました')
      # => 本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。
    end

    # 4) アカウントの有効化
    # 認証メールからアカウントの有効化処理
    activate_email = ActionMailer::Base.deliveries.last
    activate_url = extract_confirmation_url(activate_email)
    visit activate_url

    # 5) ログインの成功の確認
    visit new_user_session_path(LOCALE_JA)
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
    within(:css, flsh_css) do
      # ログイン成功の通知確認
      expect(page).to have_text('ログインしました')
    end

    # 6) ログアウトの成功の確認
    visit root_path(LOCALE_JA)
    click_link 'ログアウト'
    within(:css, flsh_css) do
      # ログイン成功の通知確認
      expect(page).to have_text('ログアウトしました')
    end
  end # scenario '新規登録 => ログイン => ログアウトのテスト'


  # 新規登録失敗テストの共通操作
  def sign_up_test(error_message, **options)
    # アカウントの新規登録ページへ遷移
    visit new_user_registration_path(LOCALE_JA)
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

  context '新規登録失敗のテスト' do
    it '名前が空欄は無効' do
      sign_up_test('ユーザ名を入力してください', name: "")
    end

    it 'Eメールが空欄は無効' do
      sign_up_test('Eメールを入力してください', email: "")
    end

    it '登録済のEメールは無効' do
      uniq_user = create(:user)
      sign_up_test('Eメールはすでに存在します', email: uniq_user.email)
    end

    it 'パスワードが6文字未満は無効' do
      sign_up_test('パスワードは6文字以上で入力してください', password: SecureRandom.alphanumeric(1+rand(5)))
    end

    it '再入力パスワードが異なる場合は無効' do
      sign_up_test('パスワード（確認用）とパスワードの入力が一致しません', password_confirmation: SecureRandom.alphanumeric(15))
    end
  end # context '新規登録失敗のテスト'
end # feature 'ユーザー認証に関するテスト'
