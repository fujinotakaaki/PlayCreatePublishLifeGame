require 'rails_helper'
# bundle exec rspec spec/features/comment_spec.rb
RSpec.describe 'Patternsビューに関するテスト', type: :feature do
  let(:user){create(:user)}
  let!(:pattern){create(:pattern)}
  let!(:patterns){create_list(:pattern, 4, category: pattern.category)}

  describe '非ログインユーザの場合' do
    before do
      visit pattern_path(id: pattern)
      pattern.reload
    end

    context '#show' do
      it '投稿情報の詳細が存在' do
        within(:css, '.patterns__show') do
          pattern_infomations = find('ul').all('li')
          expect(pattern_infomations[0]).to have_content date_format(pattern.created_at)
          expect(pattern_infomations[1]).to have_content pattern.preview_count
          expect(pattern_infomations[2]).to have_content pattern.comments_count
          expect(pattern_infomations[3]).to have_content pattern.favorites_count
        end
      end

      it 'お気に入り登録/解除ボタンが存在しないこと' do
        within(:css, '.patterns__show') do
          expect{find('ul').all('li')[3].find('a')}.to raise_error(Capybara::ElementNotFound)
        end
      end

      it '投稿の編集ボタンが存在しないこと' do
        expect(page).to_not have_selector(:css, '.patterns__edit--alignRight')
      end

      it '関連カテゴリの投稿が存在' do
        expect(find(:css, '.patterns__show--bottomRight').all(:css, '.patterns__article').count).to eq 2
      end

      it '関連カテゴリへのリンクが存在' do
        within(:css, '.patterns__show--bottomRight') do
          expect(find_link('関連するパターンを表示')).to be_truthy
        end
      end

      it 'コメント入力フォームが存在しないこと' do
        expect(page).to_not have_css '.comments__form'
      end

      it 'コメント一覧が存在' do
        expect(page).to have_css '.comments__index'
      end

      it 'コメントが無い場合のメッセージの存在' do
        within(:css, '.comments__index') do
          expect(page).to have_content 'この投稿に対するコメントはありません'
        end
      end

      it 'コメント全件取得ボタンが存在しないこと' do
        create_list(:comment, rand(6), pattern: pattern)
        visit current_path
        within(:css, '.comments__index') do
          expect(page).to_not have_css '.comments__index--more'
        end
      end

      it 'コメント全件取得ボタンが存在かつコメント取得に成功', js: true do
        create_list(:comment, 6, pattern: pattern)
        visit current_path
        within(:css, '.comments__index') do
          expect do
            find(:css, '.comments__index--more').click
          end.to change{all(:css, '.comments__article').count}.from(5).to(6)
        end
      end
    end # context '#show'
  end # describe '非ログインユーザの場合'


  describe 'ログインユーザの場合' do
    before do
      sign_in user
      visit pattern_path(id: pattern)
      pattern.reload
    end

    context '#show' do
      it 'お気に入り登録に成功', js: true do
        within(:css, '.patterns__show') do
          expect do
            find('ul').all('li')[3].find_link('登録').click
          end.to change(Favorite, :count).by(1)
        end
      end

      it 'お気に入り解除に成功', js: true do
        create(:favorite, pattern: pattern, user: user)
        visit current_path
        within(:css, '.patterns__show') do
          expect do
            accept_confirm 'お気に入りを解除しますか？' do
              find('ul').all('li')[3].find_link('解除').click
            end
            visit current_path
          end.to change(Favorite, :count).by(-1)
        end
      end

      it '投稿の編集ボタンが存在しないこと' do
        expect(page).to_not have_selector(:css, '.patterns__edit--alignRight')
      end

      it 'コメント入力フォームが存在' do
        expect(page).to have_css '.comments__form'
      end

      it 'コメントの投稿に失敗', js: true do
        expect do
          accept_alert 'コメントを入力してください' do
            find(:css, '.comments__form--submit').click
          end
        end.to_not change(PostComment, :count)
      end

      it 'コメントの投稿に成功', js: true do
        within(:css, '.patterns__show--bottomLeft') do
          comment_body = "TEST_MESSAGE_#{DateTime.now}"
          fill_in 'post_comment_body', with: comment_body
          it_puts 'コメントの投稿に成功' do
            expect do
              find(:css, '.comments__form--submit').click
            end.to change(PostComment, :count).by(1)
          end

          it_puts '入力フォームがリセットされる' do
            expect(find_by_id('post_comment_body').value).to be_blank
          end

          it_puts '投稿したコメントがページに反映される' do
            expect(first(:css, '.comments__article')).to have_content comment_body
          end
        end

        pattern.reload
        it_puts 'コメントの総数がカウントアップされる' do
          expect(find(:css, '.patterns__show').find(:css, ".comments__index--patternId\\=#{pattern.id}")).to have_content pattern.comments_count
          expect(find(:css, '.patterns__show--bottomLeft').find(:css, ".comments__index--patternId\\=#{pattern.id}")).to have_content pattern.comments_count
        end
      end
    end # context '#show'
  end # describe 'ログインユーザの場合'

  describe 'ログインユーザ（作成者）の場合' do
    before do
      sign_in pattern.user
      visit pattern_path(id: pattern)
      pattern.reload
    end

    context '#show' do
      it '投稿の編集ボタンが存在' do
        expect(page).to have_selector(:css, '.patterns__edit--alignRight')
      end
    end # context '#show'
  end # describe 'ログインユーザ（作成者）の場合'
end # describe 'Patternsビューに関するテスト'
