module LifeGameMacros
  # include MakingsHelper
  include PatternsHelper

  # PatternまたはMakingレコードからエミュレータ画面に表示されるテキストを構築する
  def build_life_game_text_from(object)
    unless object.is_a?(Pattern) || object.is_a?(Making) then
      Kernel.throw :error
    end
    bitstrings = build_up_bit_strings_from(object)
    bitstrings_to_text(bitstrings, object.display_format.as_pattern[:cellConditions])
    # ex) グライダー
    # '□□□□□\n□□■□□\n□□□■□\n□■■■□\n□□□□□'
  end

  # ビット列をエミュレータ画面に表示されるテキストを構築する
  def bitstrings_to_text( bitstrings = [], **options )
    options[:alive] ||= ?■
    options[:dead] ||= ?□
    bitstrings.map! do |bitstring|
      bitstring.gsub(/1/, options[:alive]).gsub(/0/, options[:dead])
    end
    bitstrings.join("\n")
    # ex) グライダー
    # '□□□□□\n□□■□□\n□□□■□\n□■■■□\n□□□□□'
  end

  # GLIDER = [
  class Glider5x5
    def self.loop(generation=0)
      [
        %w(
          00000
          00100
          00010
          01110
          00000
        ),
        %w(
          00000
          00000
          01010
          00110
          00100
        ),
        %w(
          00000
          00000
          00010
          01010
          00110
        ),
        %w(
          00000
          00000
          00100
          00011
          00110
        ),
        %w(
          00000
          00000
          00010
          00001
          00111
        ),
        %w(
          00010
          00000
          00000
          00101
          00011
        ),
        %w(
          00011
          00000
          00000
          00001
          00101
        ),
        %w(
          00011
          00000
          00000
          00010
          10001
        ),
        %w(
          10011
          00000
          00000
          00001
          10000
        ),
        %w(
          10001
          00001
          00000
          00000
          10010
        ),
        %w(
          10010
          10001
          00000
          00000
          10000
        ),
        %w(
          11000
          10001
          00000
          00000
          00001
        ),
        %w(
          01000
          11001
          00000
          00000
          10000
        ),
        %w(
          01001
          11000
          10000
          00000
          00000
        ),
        %w(
          01000
          01001
          11000
          00000
          00000
        ),
        %w(
          10000
          01100
          11000
          00000
          00000
        ),
        %w(
          01000
          00100
          11100
          00000
          00000
        ),
        %w(
          00000
          10100
          01100
          01000
          00000
        ),
        %w(
          00000
          00100
          10100
          01100
          00000
        ),
        %w(
          00000
          01000
          00110
          01100
          00000
        )
        ][generation%20]
      end # self.loop(generation=0)
    end # class Glider
  end # module LifeGameMacros
