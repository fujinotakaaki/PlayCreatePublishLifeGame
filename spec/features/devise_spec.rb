require 'rails_helper'
RSpec.feature 'ユーザー認証のテスト' do
  # アカウント有効化のリンク取得メソッド
  def extract_confirmation_url(email)
    body = email.body.encoded
    # メール内のリンクは１つしかないため問題なし
    body[/http[^"]+/]
  end

  LOCALE_JA = { locale: :ja }
  let(:user){build(:user, confirmed_at: nil)}

  context 'アカウントの新規登録に関するテスト' do
    after do
      ActionMailer::Base.deliveries.clear
    end

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
      # アカウントの新規登録ページへ
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
    end
  end
end
