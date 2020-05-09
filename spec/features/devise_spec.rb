require 'rails_helper'
RSpec.feature 'ユーザー認証のテスト' do
  # before do
  #   # アカウントの新規登録ページへ遷移
  #   visit new_user_registration_path(LOCALE_JA)
  # end

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

  context 'アカウントの新規登録に関するテスト' do
    scenario '新規登録〜ログイン成功までのテスト' do
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
    end # scenario '新規登録〜ログイン成功までのテスト'

    scenario '新規登録失敗のテスト' do
      def sign_up_test(**options)
        # アカウントの新規登録ページへ遷移
        visit new_user_registration_path(LOCALE_JA)
        # 入力用のデータを作成
        test_user = build(:user, confirmed_at: nil)
        # 入力する値を変更する（パスワードのみ）
        if options.has_key?(:password) then
          test_user.password = options.delete(:password)
        end
        # 入力する値を変更する（パスワード以外）
        options.each do |key, value|
          test_user[key] = value
        end
        # フォームに値を入力
        fill_in 'user[name]', with: test_user.name
        fill_in 'user[email]', with: test_user.email
        fill_in 'user[password]', with: test_user.password
        yield test_user if block_given? # 再入力パスワード変更する場合はここで実行
        fill_in 'user[password_confirmation]', with: test_user.password
        # レコードが作成されていないことを確認
        expect { click_button 'アカウント作成' }.to_not change { User.count }
      end

      # 名前が空欄は無効
      sign_up_test(name: "")
      # Eメールが空欄は無効
      sign_up_test(email: "")
      # パスワードが6文字未満は無効
      sign_up_test(password: SecureRandom.alphanumeric(rand(6)))
      # 再入力パスワードが異なる場合は無効
      sign_up_test {|test_user| test_user.password = SecureRandom.alphanumeric(15) }
    end # scenario '新規登録失敗のテスト'
  end # context 'アカウントの新規登録に関するテスト'
end # feature 'ユーザー認証のテスト'
