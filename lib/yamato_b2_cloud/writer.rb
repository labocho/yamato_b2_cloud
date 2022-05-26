require "csv"
require "windows_31j_punctuation"

module YamatoB2Cloud
  class Writer
    UNSUPPORTED_CHARACTER_CONVERSIONS ={
      "𠷡" => "百合",
      "𠮷" => "吉",
      "\u{00a0}" => " ",
    }.each {|k, v|
      k.freeze
      v.freeze
    }.freeze

    attr_reader :csv

    def initialize
      @csv = ::CSV.new("", row_sep: "\r\n")
      csv << Record.headers
    end

    # @param record [YamatoB2Cloud::Record]
    def <<(record)
      csv << record.to_a
    end

    def to_s
      s = convert_before_encode(csv.string)
      s.encode("cp932")
    end

    private
    def convert_before_encode(s)
      s = Windows31jPunctuation.replace(csv.string) # 見た目の似た記号を統一 https://y-kawaz.hatenadiary.org/entry/20101112/1289554290
      s = avoid_wave_dash_problem(s)
      s = convert_unsupported_characters(s)
      s
    end

    # UTF-8 から CP932 への変換に失敗する文字を置き換え
    # https://qiita.com/motoki1990/items/fd7473f4d1e28c6a3ed6
    def avoid_wave_dash_problem(utf8s)
      utf8s.tr(
        "¢£¬‖".freeze,
        "￠￡￢∥".freeze,
      )
    end

    # ヤマトB2クラウドでは JIS 第一・二水準の漢字のみ対応とある。
    # https://b-faq.kuronekoyamato.co.jp/app/answers/detail/a_id/406/kw/B2%E3%82%AF%E3%83%A9%E3%82%A6%E3%83%89%E3%81%AE%E5%A4%96%E9%83%A8%E3%83%87%E3%83%BC%E3%82%BF%E5%8F%96%E3%82%8A%E8%BE%BC%E3%81%BF%E3%81%A7%E3%80%81%E5%85%A5%E5%8A%9B%E6%99%82%E3%81%AE%E5%88%B6%E9%99%90%E3%83%BB%E5%AF%BE%E5%BF%9C%E3%81%97%E3%81%A6%E3%81%84%E3%82%8B%E6%96%87%E5%AD%97%E3%82%B3%E3%83%BC%E3%83%89
    # 第三・四水準の漢字のすべての変換を定義するのは現実的ではないので、必要になったときに追加していく。
    def convert_unsupported_characters(s)
      UNSUPPORTED_CHARACTER_CONVERSIONS.each do |k1, k2|
        s.gsub!(k1, k2)
      end
      s
    end
  end
end
