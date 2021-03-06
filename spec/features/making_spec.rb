# rack_testでは#visible?でfalseとなるのは、style="display: none;"またはhidden属性のみ
# つまりCSS（スタイルシート）の設定は無視される
# https://stackoverflow.com/questions/40825218/checking-for-visibility-with-capybara
require 'rails_helper'
# bundle exec rspec spec/features/making_spec.rb
RSpec.describe "パターン作成ページのテスト", type: :feature, js: true do # Making#editページ
  let(:making_fresh_off){create(:making)}
  let(:making){create(:making_random)}
  let(:filled_sample_text){attributes_for(:making, :filled_sample)[:making_text]}
  let(:unfilled_sample_text){attributes_for(:making, :unfilled_sample)[:making_text]}
  before do
    create(:display_format, id: 1)
    sign_in making_fresh_off.user
    visit edit_making_path
  end


  context 'ページ上のDOM要素に関するテスト' do
    it 'パターン作成に必要なアクションボタン存在の確認', aggregate_failures: true do
      ## フォームに関するテスト
      it_puts 'トーラス面設定用のラジオボタンが存在' do
        expect(page.has_css?('#making_is_torus_true') && page.has_css?('#making_is_torus_false')).to be_truthy
      end

      it_puts 'パターン編集フォームに説明文が存在' do
        this_field = find(:css, '.makings__edit--textarea')
        expect(this_field.text).to include 'パターン作成の説明'
      end

      it_puts 'セルの縮尺設定用のスケールバーが存在' do
        expect(page).to have_css '#making_transform_scale_rate'
      end

      it_puts '変更を保存ボタンが存在かつ非表示' do
        this_button = find(:css, '#makings__edit--update', visible: false) # Makings#updateリクエスト
        expect(this_button.visible?).to be_falsey
      end

      ## その他についてのテスト
      it_puts '検証ボタンが存在' do
        this_button = find(:css, '.makings__edit--verification', visible: false) # 作成中のパターンの有効確認
        expect(this_button.visible?).to be_truthy
      end

      it_puts 'パターンを投稿ボタンが存在かつ非表示' do
        this_button = find(:css, '#patterns__new--jump', visible: false)   # Patterns#newリクエスト
        expect(this_button.visible?).to be_falsey
      end
    end # it 'パターン作成に必要なアクションボタン存在の確認'

    it 'ナビゲーションタグの挙動のテスト' do
      it_puts 'classにactiveを有する要素は唯一であること' do
        within(:css, '.makings__edit--tabNav') do
          active_li = all(:css, '.active')
          expect(active_li.count).to eq 1
        end
      end

      it_puts 'アクティブタグは基本操作タグであること' do
        re = /[^#]++\Z/
        active_li = find(:css, '.makings__edit--tabNav').find(:css, '.active')
        re =~ active_li.find('a')[:href]
        active_div = find_by_id(Regexp.last_match[0])
        expect(active_li.text).to eq '基本操作'
        expect(find(:css, '.tab-content').find('div', class: 'active')).to eq active_div
      end

      it_puts 'アクティブタグの切り替えに成功' do
        re = /[^#]++\Z/
        active_li = find(:css, '.makings__edit--tabNav').find('li', class: 'active')
        re =~ active_li.find('a')[:href]
        active_div = find_by_id(Regexp.last_match[0])
        nonactive_li = find(:css, '.makings__edit--tabNav').all('li', class: '!active').sample
        re =~ nonactive_li.find('a')[:href]
        nonactive_div = find_by_id(Regexp.last_match[0], visible: false)
        expect do
          nonactive_li.find('a').click
        end.to change{find(:css, '.makings__edit--tabNav').find('li', class: 'active')}.from(active_li).to(nonactive_li). # 厳密には違うはず（activeがないはずだから）
        and change{find(:css, '.tab-content').find('div', class: 'active')}.from(active_div).to(nonactive_div) # 厳密には違うはず（activeがないはずだから）
        # active_li       = #<Capybara::Node::Element tag="li" path="/HTML/BODY[1]/MAIN[1]/DIV[1]/DIV[1]/DIV[1]/DIV[1]/FORM[1]/H3[1]/UL[1]/LI[1]">
        # nonactive_li = #<Capybara::Node::Element tag="li" path="/HTML/BODY[1]/MAIN[1]/DIV[1]/DIV[1]/DIV[1]/DIV[1]/FORM[1]/H3[1]/UL[1]/LI[4]">
        # オブジェクト番号みたいなので比較するから中身までは厳密に比較しないのだろうか
      end
    end # it 'ナビゲーションタグの挙動のテスト'
  end # context 'ページ上のDOM要素に関するテスト'


  describe '機能のテスト' do
    context '入力機能', aggregate_failures: true do
      it "入力した値をパターン反映に成功" do
        random_bit_strings = Array.new(rand(5..10)){?0*rand(0..10)+rand(0...1024).to_s(2)}.join("\n")
        fill_in 'making_making_text', with: random_bit_strings
        expect_making_textarea random_bit_strings
        expect_making_display bitstrings_to_text(random_bit_strings)
      end

      it '0と1以外の入力の阻害に成功' do
        it_puts 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' do
          fill_in 'making_making_text', with: "abcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789"
          expect_making_textarea "01"
          expect_making_display bitstrings_to_text("01")
        end

        it_puts '3.1415926535\n8979323846\n2643383279\n5028841971\n6939937510\n5820974944' do
          fill_in 'making_making_text', with: "3.1415926535\n8979323846\n2643383279\n5028841971\n6939937510\n5820974944"
          expect_making_textarea "11\n\n\n011\n10\n0"
          expect_making_display bitstrings_to_text("11\n\n\n011\n10\n0")
        end
      end
    end # context '入力機能'
    # 0or1から入力する場合とそれ以外の文字から入力する場合で元からある改行が消えたり残ったりする
    # マッチャをeqからhave_contentにすると解消される
    # 「改行」や「連続する空白文字」の扱いが変化するためらしい
    # https://journal.sooey.com/274
    # https://github.com/teamcapybara/capybara/blob/master/History.md#version-300rc2


    context '基本操作機能' do
      context '作成中のパターンの保存について' do
        it '適切なパターンの保存に成功' do
          fill_in 'making_making_text', with: filled_sample_text
          find(:css, '.makings__edit--verification').click
          expect(find(:css, '.application__alert--common')).to have_content '保存可能なパターンです'
          find_by_id('makings__edit--update').click
          expect(find(:css, '.application__alert--common')).to have_content '更新に成功しました'
          making_fresh_off.reload
          expect(making_fresh_off.normalized_rows_sequence).to eq '6,b,9,a'
        end

        it '不適切なパターンの保存に失敗' do
          fill_in 'making_making_text', with: unfilled_sample_text
          find(:css, '.makings__edit--verification').click
          expect(find(:css, '.application__alert--common')).to have_content 'パターンが不揃いです'
          making_fresh_off.reload
          expect(making_fresh_off.normalized_rows_sequence).to be_nil
        end
      end # context '作成中のパターンの保存について'

      context '空のパターン作成メソッド' do
        it '空のパターンの作成に成功' do
          height = rand(1..300)
          width = rand(1..300)
          fill_in_size(height, width)
          accept_confirm '編集中の内容は消えますがよろしいですか？' do
            find(:css, '.makings__edit--createBlankPattern').find('button').click
          end
          expect_making_text = Array.new(height, ?0*width).join("\n")
          expect_making_textarea expect_making_text
          expect_making_display bitstrings_to_text(expect_making_text)
        end

        it 'キャンセルに成功' do
          height = rand(1..300)
          width = rand(1..300)
          fill_in_size(height, width)
          dismiss_confirm '編集中の内容は消えますがよろしいですか？' do
            find(:css, '.makings__edit--createBlankPattern').find('button').click
          end
          expect_making_textarea 'パターン作成'
        end

        it '0は無効' do
          height = rand(1..300)
          width = 0
          fill_in_size(height, width)
          accept_alert '入力サイズが不適切です' do
            find(:css, '.makings__edit--createBlankPattern').find('button').click
          end
        end

        it '負の値は無効' do
          height = rand(1..300)
          width = -1
          fill_in_size(height, width)
          accept_alert '入力サイズが不適切です' do
            find(:css, '.makings__edit--createBlankPattern').find('button').click
          end
        end

        it '300より大きい値は無効' do
          height = rand(1..300)
          width = 301
          fill_in_size(height, width)
          accept_alert '入力サイズが不適切です' do
            find(:css, '.makings__edit--createBlankPattern').find('button').click
          end
        end
      end # context '空のパターン作成メソッド'
    end # context '基本操作機能'


    context '一斉操作機能' do
      before do
        fill_in 'making_making_text', with: filled_sample_text
        find_link(href: '#sampleContentB').click
      end

      it '上側に行の追加に成功' do
        find_button('上に行を追加').click
        expect_making_textarea "0000\n0110\n1011\n1001\n1010"
        expect_making_display bitstrings_to_text("0000\n0110\n1011\n1001\n1010")
      end

      it '下側に行の追加に成功' do
        find_button('下に行を追加').click
        expect_making_textarea "0110\n1011\n1001\n1010\n0000"
        expect_making_display bitstrings_to_text("0110\n1011\n1001\n1010\n0000")
      end

      it '左側に列の追加に成功' do
        find_button('左に列を追加').click
        expect_making_textarea "00110\n01011\n01001\n01010"
        expect_making_display bitstrings_to_text("00110\n01011\n01001\n01010")
      end

      it '右側に列の追加に成功' do
        find_button('右に列を追加').click
        expect_making_textarea "01100\n10110\n10010\n10100"
        expect_making_display bitstrings_to_text("01100\n10110\n10010\n10100")
      end

      it '上側の行の削除に成功' do
        find_button('上の行を削除').click
        expect_making_textarea "1011\n1001\n1010"
        expect_making_display bitstrings_to_text("1011\n1001\n1010")
      end

      it '下側の行の削除に成功' do
        find_button('下の行を削除').click
        expect_making_textarea "0110\n1011\n1001"
        expect_making_display bitstrings_to_text("0110\n1011\n1001")
      end

      it '左側の列の削除に成功' do
        find_button('左の列を削除').click
        expect_making_textarea "110\n011\n001\n010"
        expect_making_display bitstrings_to_text("110\n011\n001\n010")
      end

      it '右側の列の削除に成功' do
        find_button('右の列を削除').click
        expect_making_textarea "011\n101\n100\n101"
        expect_making_display bitstrings_to_text("011\n101\n100\n101")
      end
    end # context '一斉操作セクション'


    context '補完処理機能' do
      before do
        find_link(href: '#sampleContentC').click
      end

      it '左側の補完に成功' do
        fill_in 'making_making_text', with: unfilled_sample_text
        find_by_id('sampleContentC').find_button('左側').click
        expect_making_textarea "00001\n00011\n00101\n01001\n10001"
        expect_making_display bitstrings_to_text("00001\n00011\n00101\n01001\n10001")
      end

      it '右側の補完に成功' do
        fill_in 'making_making_text', with: unfilled_sample_text
        find_by_id('sampleContentC').find_button('右側').click
        expect_making_textarea "10000\n11000\n10100\n10010\n10001"
        expect_making_display bitstrings_to_text("10000\n11000\n10100\n10010\n10001")
      end
    end # context '補完処理機能'


    context '特殊処理機能' do
      before do
        fill_in 'making_making_text', with: filled_sample_text
        find_by_id('sampleContentA').find_button('検証').click
        find_link(href: '#sampleContentD').click
      end

      it '上下反転' do
        flip_button = find_by_id('sampleContentD').find_button('上下反転')
        # 上下反転の確認
        flip_button.click
        expect_making_textarea "1010\n1001\n1011\n0110"
        expect_making_display bitstrings_to_text("1010\n1001\n1011\n0110")
        # 元に戻るか確認
        flip_button.click
        expect_making_textarea filled_sample_text
        expect_making_display bitstrings_to_text(filled_sample_text)
      end

      it '左右反転' do
        flip_button = find_by_id('sampleContentD').find_button('左右反転')
        # 左右反転の確認
        flip_button.click
        expect_making_textarea "0110\n1101\n1001\n0101"
        expect_making_display bitstrings_to_text("0110\n1101\n1001\n0101")
        # 元に戻るか確認
        flip_button.click
        expect_making_textarea filled_sample_text
        expect_making_display bitstrings_to_text(filled_sample_text)
      end

      it '反時計回りに回転' do
        rotation_button = find_by_id('sampleContentD').find_button('反時計回りに回転')
        it_puts '90度回転' do
          rotation_button.click
          expect_making_textarea "0110\n1101\n1000\n0111"
          expect_making_display bitstrings_to_text("0110\n1101\n1000\n0111")
        end
        it_puts '180度回転' do
          rotation_button.click
          expect_making_textarea "0101\n1001\n1101\n0110"
          expect_making_display bitstrings_to_text("0101\n1001\n1101\n0110")
        end
        it_puts '270度回転' do
          rotation_button.click
          expect_making_textarea "1110\n0001\n1011\n0110"
          expect_making_display bitstrings_to_text("1110\n0001\n1011\n0110")
        end
        # 元に戻るか確認
        it_puts '360度回転' do
          rotation_button.click
          expect_making_textarea filled_sample_text
          expect_making_display bitstrings_to_text(filled_sample_text)
        end
      end
    end # context '特殊処理機能'


    context 'パターン合成機能' do
      let!(:block){create(:block)}
      let!(:glider){create(:glider)}
      let!(:octagon){create(:octagon)}
      let!(:step4){create(:step4)}
      before do
        Capybara.reset_sessions!
        sign_in making_fresh_off.user
        visit edit_making_path
      end

      # 4x3マスとブロックの合成に成功
      it 'テストケース1' do
        fill_in_size(4,3)
        accept_confirm '編集中の内容は消えますがよろしいですか？' do
          find(:css, '.makings__edit--createBlankPattern').find('button').click
        end
        find_link(href: '#sampleContentE').click
        within(:css, '#sampleContentE') do
          select(block.name)
          expect(page).to have_content 'このパターンは使用可能です'
          expect_coupler_preview bitstrings_to_text("11\n11")
          expect do
            find(:css, '.makings__edit--startCoupling').click
          end.to change{page.has_text?('手順２')}.from(be_falsey).to(be_truthy)
        end
        execute_script "keypressHelper('down')"
        find_button('設置').click
        expect_making_display bitstrings_to_text("000\n110\n110\n000")
        find_link(href: '#sampleContentA').click
        find(:css, '.makings__edit--verification').click
        expect(find(:css, '.application__alert--common')).to have_content '保存可能なパターンです'
        find_by_id('makings__edit--update').click
        expect(find(:css, '.application__alert--common')).to have_content '更新に成功しました'
      end

      # 合成のキャンセルに成功
      it 'テストケース2' do
        fill_in_size(5,5)
        accept_confirm '編集中の内容は消えますがよろしいですか？' do
          find(:css, '.makings__edit--createBlankPattern').find('button').click
        end
        find_link(href: '#sampleContentE').click
        # 1コ目の合成処理
        within(:css, '#sampleContentE') do
          select(step4.name)
          expect(page).to have_content 'このパターンは使用可能です'
          expect_coupler_preview bitstrings_to_text("1000\n1100\n1110\n1111")
          expect do
            find(:css, '.makings__edit--startCoupling').click
          end.to change{page.has_text?('手順２')}.from(be_falsey).to(be_truthy)
        end
        window_key_sends('right')
        window_key_sends('down')
        window_key_sends('down', shiftKey: true)
        expect_making_display bitstrings_to_text(<<~FIRST)
        00000
        01111
        01110
        01100
        01000
        FIRST
        find_button('中止').click
        expect_making_display bitstrings_to_text(<<~FIRST)
        00000
        00000
        00000
        00000
        00000
        FIRST
        find_link(href: '#sampleContentA').click
        find(:css, '.makings__edit--verification').click
        expect(find(:css, '.application__alert--common')).to have_content '「生」セルがありません'
      end

      # 3x1マスとブロックでは、幅が足りないため合成できないこと
      it 'テストケース3' do
        fill_in_size(3,1)
        accept_confirm '編集中の内容は消えますがよろしいですか？' do
          find(:css, '.makings__edit--createBlankPattern').find('button').click
        end
        find_link(href: '#sampleContentE').click
        within(:css, '#sampleContentE') do
          select(block.name)
          expect(page).to have_content 'このパターンは使用できません'
          expect_coupler_preview bitstrings_to_text("11\n11")
          expect(find(:css, '.makings__edit--startCoupling').disabled?).to be_truthy
        end
      end

      # 1x3マスとブロックでは、高さが足りないため合成できないこと
      it 'テストケース4' do
        fill_in_size(1,3)
        accept_confirm '編集中の内容は消えますがよろしいですか？' do
          find(:css, '.makings__edit--createBlankPattern').find('button').click
        end
        find_link(href: '#sampleContentE').click
        within(:css, '#sampleContentE') do
          select(block.name)
          expect(page).to have_content 'このパターンは使用できません'
          expect_coupler_preview bitstrings_to_text("11\n11")
          expect(find(:css, '.makings__edit--startCoupling').disabled?).to be_truthy
        end
      end

      # 10x10マスに八角形を中央に配置し、合成に成功
      it 'テストケース5' do
        fill_in_size(10,10)
        accept_confirm '編集中の内容は消えますがよろしいですか？' do
          find(:css, '.makings__edit--createBlankPattern').find('button').click
        end
        find_link(href: '#sampleContentE').click
        within(:css, '#sampleContentE') do
          select(octagon.name)
          expect(page).to have_content 'このパターンは使用可能です'
          expect_coupler_preview bitstrings_to_text(<<~OCTAGON)
          010010
          101101
          010010
          010010
          101101
          010010
          OCTAGON
          expect do
            find(:css, '.makings__edit--startCoupling').click
          end.to change{page.has_text?('手順２')}.from(be_falsey).to(be_truthy)
        end
        2.times do
          window_key_sends('down')
          window_key_sends('right')
        end
        find_button('設置').click
        expect_making_display bitstrings_to_text(<<~OCTAGON)
        0000000000
        0000000000
        0001001000
        0010110100
        0001001000
        0001001000
        0010110100
        0001001000
        0000000000
        0000000000
        OCTAGON
        find_link(href: '#sampleContentA').click
        find(:css, '.makings__edit--verification').click
        expect(find(:css, '.application__alert--common')).to have_content '保存可能なパターンです'
        find_by_id('makings__edit--update').click
        expect(find(:css, '.application__alert--common')).to have_content '更新に成功しました'
      end

      # 5x13マスと２個のグライダーの合成に成功
      # 左右反転操作
      # 回転操作
      # 10マス跳び移動
      # 連続同パターン合成
      it 'テストケース6' do
        fill_in_size(5,13)
        accept_confirm '編集中の内容は消えますがよろしいですか？' do
          find(:css, '.makings__edit--createBlankPattern').find('button').click
        end
        find_link(href: '#sampleContentE').click
        within(:css, '#sampleContentE') do
          select(glider.name)
          expect(page).to have_content 'このパターンは使用可能です'
          expect_coupler_preview bitstrings_to_text("010\n001\n111")
          expect do
            find(:css, '.makings__edit--startCoupling').click
          end.to change{page.has_text?('手順２')}.from(be_falsey).to(be_truthy)
        end
        3.times do
          window_key_sends('right')
          window_key_sends('r')
          window_key_sends('down')
        end
        find_button('設置').click
        expect_making_display bitstrings_to_text(<<~FIRST)
        0000000000000
        0000000000000
        0001000000000
        0001010000000
        0001100000000
        FIRST
        expect(find(:css, '.makings__edit--startCoupling').disabled?).to be_falsey
        find(:css, '.makings__edit--startCoupling').click
        window_key_sends('r')
        window_key_sends('right', altKey: true)
        window_key_sends('right', shiftKey: true)
        find_button('設置').click
        expect_making_display bitstrings_to_text(<<~SECOND)
        0000000000010
        0000000000100
        0001000000111
        0001010000000
        0001100000000
        SECOND
        find_link(href: '#sampleContentA').click
        find(:css, '.makings__edit--verification').click
        expect(find(:css, '.application__alert--common')).to have_content '保存可能なパターンです'
        find_by_id('makings__edit--update').click
        expect(find(:css, '.application__alert--common')).to have_content '更新に成功しました'
      end

      # 連続異種パターン合成に成功
      it 'テストケース7' do
        fill_in_size(15,15)
        accept_confirm '編集中の内容は消えますがよろしいですか？' do
          find(:css, '.makings__edit--createBlankPattern').find('button').click
        end
        find_link(href: '#sampleContentE').click
        # 1コ目の合成処理
        within(:css, '#sampleContentE') do
          select(step4.name)
          expect(page).to have_content 'このパターンは使用可能です'
          expect_coupler_preview bitstrings_to_text("1000\n1100\n1110\n1111")
          expect do
            find(:css, '.makings__edit--startCoupling').click
          end.to change{page.has_text?('手順２')}.from(be_falsey).to(be_truthy)
        end
        window_key_sends('right', altKey: true)
        window_key_sends('r')
        3.times {window_key_sends('left')}
        find_button('設置').click
        expect_making_display bitstrings_to_text(<<~FIRST)
        000000000010000
        000000000110000
        000000001110000
        000000011110000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        FIRST
        # 2コ目の合成処理
        within(:css, '#sampleContentE') do
          select(glider.name)
          expect(page).to have_content 'このパターンは使用可能です'
          expect_coupler_preview bitstrings_to_text("010\n001\n111")
          expect do
            find(:css, '.makings__edit--startCoupling').click
          end.to change{page.has_text?('手順２')}.from(be_falsey).to(be_truthy)
        end
        window_key_sends('right', altKey: true)
        window_key_sends('down', altKey: true)
        window_key_sends('up')
        find_button('設置').click
        expect_making_display bitstrings_to_text(<<~SECOND)
        000000000010000
        000000000110000
        000000001110000
        000000011110000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000000000
        000000000001000
        000000000000100
        000000000011100
        000000000000000
        000000000000000
        000000000000000
        SECOND
        # 3コ目の合成処理
        within(:css, '#sampleContentE') do
          select(octagon.name)
          expect(page).to have_content 'このパターンは使用可能です'
          expect_coupler_preview bitstrings_to_text("010010\n101101\n010010\n010010\n101101\n010010")
          expect do
            find(:css, '.makings__edit--startCoupling').click
          end.to change{page.has_text?('手順２')}.from(be_falsey).to(be_truthy)
        end
        5.times do
          window_key_sends('right')
          window_key_sends('down')
        end
        find_button('設置').click
        expect_making_display bitstrings_to_text(<<~THIRD)
        000000000010000
        000000000110000
        000000001110000
        000000011110000
        000000000000000
        000000100100000
        000001011010000
        000000100100000
        000000100100000
        000001011011000
        000000100100100
        000000000011100
        000000000000000
        000000000000000
        000000000000000
        THIRD
        find_link(href: '#sampleContentA').click
        find(:css, '.makings__edit--verification').click
        expect(find(:css, '.application__alert--common')).to have_content '保存可能なパターンです'
        find_by_id('makings__edit--update').click
        expect(find(:css, '.application__alert--common')).to have_content '更新に成功しました'
      end
    end # context 'パターン合成機能'


    context '画像から作成機能' do
      before do
        find_link(href: '#sampleContentF').click
      end

      it 'ページ遷移に成功' do
        find_by_id('sampleContentF').find('a').click
        expect(current_path).to eq new_making_path(locale: I18n.default_locale)
      end
    end # context '画像から作成機能'


    context 'パターンの初期化機能' do
      before do
        sign_in making.user
        visit edit_making_path
        find_link(href: '#sampleContentG').click
      end

      it '中断に成功' do
        reset_button = find_by_id('sampleContentG').find('a')
        expect(page).to_not have_content 'パターン作成の説明'
        # aタグではURLが無いというエラーになるため、
        dismiss_confirm "作成中のパターンを初期化しますか？" do
          reset_button.find('p').click
        end
        expect(page).to_not have_content 'パターン作成の説明'
        making.reload
        expect(making.normalized_rows_sequence).to_not be_nil
      end

      it '実行に成功' do
        reset_button = find_by_id('sampleContentG').find('a')
        expect(page).to_not have_content 'パターン作成の説明'
        # aタグではURLが無いというエラーになるため、
        accept_confirm "作成中のパターンを初期化しますか？" do
          reset_button.find('p').click
        end
        visit edit_making_path # 本来は必要ない
        expect_making_textarea 'パターン作成の説明'
        expect{making.reload}.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end # context 'パターンの初期化機能'
  end # describe '機能のテスト'
end # RSpec.describe "パターン作成ページのテスト"
