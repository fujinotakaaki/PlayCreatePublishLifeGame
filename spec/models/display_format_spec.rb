require 'rails_helper'

RSpec.describe 'DisplayFormatモデルのバリデーションテスト', type: :model do
  let(:display_format){ create(:display_format) }

  context 'nameカラム' do
    it '空欄でないこと' do
      display_format.name = ""
      expect(display_format.valid?).to eq false
      display_format.name = " "
      expect(display_format.valid?).to eq false
      display_format.name = "　"
      expect(display_format.valid?).to eq false
    end
  end

  context 'line_height_rateカラム' do
    it '空欄でないこと' do
      display_format.line_height_rate = ""
      expect(display_format.valid?).to eq false
      display_format.line_height_rate = " "
      expect(display_format.valid?).to eq false
      display_format.line_height_rate = "　"
      expect(display_format.valid?).to eq false
    end

    it '正の値であること' do
      display_format.line_height_rate = -1
      expect(display_format.valid?).to eq false
    end
  end

  describe 'セルの表示形式に関する項目' do
    context 'aliveカラムについて' do
      it '半角の0でないこと' do
        display_format.alive = ?0
        expect(display_format.valid?).to eq false
      end

      it '1文字であること' do
        display_format.alive = ""
        expect(display_format.valid?).to eq false
        display_format.alive = ?a * (2+rand(100))
        expect(display_format.valid?).to eq false
      end

      it 'deadカラムと一致しないこと' do
        display_format.alive = display_format.dead
        expect(display_format.valid?).to eq false
      end
    end

    context 'deadカラムについて' do
      it '1文字であること' do
        display_format.dead = ""
        expect(display_format.valid?).to eq false
        display_format.dead = ?a * (2+rand(100))
        expect(display_format.valid?).to eq false
      end

      it 'aliveカラムと一致しないこと' do
        display_format.dead = display_format.alive
        expect(display_format.valid?).to eq false
      end
    end
  end

  describe '表示色に関する項目' do
    context 'font_colorカラムについて' do
      it 'background_colorカラムと一致しないこと' do
        display_format.font_color  = display_format.background_color
        expect(display_format.valid?).to eq false
      end
    end

    context 'background_color カラムについて' do
      it 'font_colorカラムと一致しないこと' do
        display_format.background_color  = display_format.font_color
        expect(display_format.valid?).to eq false
      end
    end
  end

  context 'letter_spacingカラム' do
    it '数字であること' do
      display_format.letter_spacing = ""
      expect(display_format.valid?).to eq false
      display_format.letter_spacing = "０"
      expect(display_format.valid?).to eq false
      display_format.letter_spacing = "0.1"
      expect(display_format.valid?).to eq true
      display_format.letter_spacing = "-1"
      expect(display_format.valid?).to eq true
    end
  end

  context 'font_sizeカラム' do
    it '0以上の数字であること' do
      display_format.font_size = ""
      expect(display_format.valid?).to eq false
      display_format.font_size = "０"
      expect(display_format.valid?).to eq false
      display_format.font_size = "0"
      expect(display_format.valid?).to eq true
      display_format.font_size = "-1"
      expect(display_format.valid?).to eq false
    end
  end

end
