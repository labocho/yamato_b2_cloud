require "spec_helper"

module YamatoB2Cloud
  RSpec.describe Writer do
    let(:writer) { Writer.new }
    let(:record) {
      Record.new(
        type: Record::TYPE.COLLECT,
        shipping_date: Date.new(2019, 11, 13),
        delivery_date: Date.new(2019, 11, 14),
        delivery_time: Record::DELIVERY_TIME.FROM_08_TO_12,
        receiver_phone_number: "08012345678",
        receiver_postal_code: "1234567",
        receiver_line_1: "送り先住所1",
        receiver_line_2: "送り先住所2",
        receiver_name: "送り先名前",
        sender_phone_number: "0591112222",
        sender_postal_code: "2345678",
        sender_line_1: "依頼主住所1",
        sender_line_2: "依頼主住所2",
        sender_name: "依頼主名前",
        description: "品名",
        print_number_of_boxes_frame: Record::PRINT_NUMBER_OF_BOXES_FRAME.NONE,
        billing_customer_code: "0592223333",
        shipping_fee_management_number: "01",
        collect_amount_within_tax: 12345,
        collect_amount_tax: 123,
        note_to_deliverer: "記事",
        search_key_title_1: "検索キー1",
        search_key_1: "sk1",
        search_key_title_2: "検索キー2",
        search_key_2: "sk2",
        search_key_title_3: "検索キー3",
        search_key_3: "sk3",
        search_key_title_4: "検索キー4",
        search_key_4: "sk4",
        search_key_title_5: "検索キー5",
        search_key_5: "sk5",
      )
    }

    describe "to_s" do
      let(:s) {
        writer
        writer << record
        writer.to_s
      }
      let(:decoded) { CSV.new(s.encode("utf-8"), row_sep: "\r\n", headers: :first_line) }
      subject { s }

      it "is encoded with cp932" do
        expect(s.encoding).to eq(Encoding::CP932)
      end

      it "uses \\r\\n as new line" do
        should match(/\r\n$/)
      end

      it {
        should eq <<~CSV.encode("cp932").gsub("\n", "\r\n")
          ,type,,,shipping_date,delivery_date,delivery_time,,receiver_phone_number,,receiver_postal_code,receiver_line_1,receiver_line_2,,,receiver_name,,,,sender_phone_number,,sender_postal_code,sender_line_1,sender_line_2,sender_name,,,description,,,,,note_to_deliverer,collect_amount_within_tax,collect_amount_tax,,,,print_number_of_boxes_frame,billing_customer_code,,shipping_fee_management_number,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,search_key_title_1,search_key_1,search_key_title_2,search_key_2,search_key_title_3,search_key_3,search_key_title_4,search_key_4,search_key_title_5,search_key_5
          ,2,,,2019/11/13,2019/11/14,0812,,080-1234-5678,,123-4567,送り先住所1,送り先住所2,,,送り先名前,,,,059-111-2222,,234-5678,依頼主住所1,依頼主住所2,依頼主名前,,,品名,,,,,記事,12345,123,,,,2,0592223333,,01,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,検索キー1,sk1,検索キー2,sk2,検索キー3,sk3,検索キー4,sk4,検索キー5,sk5
        CSV
      }

      it "converts CENT SIGN (U+00A2) to FULLWIDTH CENT SIGN (U+FFE0)" do
        record.receiver_name = "foo¢bar"
        expect(decoded.each.first["receiver_name"]).to eq "foo￠bar"
      end

      it "converts WAVE DASH (U+301C) to FULLWIDTH TILDE (U+FF5E)" do
        record.receiver_name = "foo\u{301c}bar"
        expect(decoded.each.first["receiver_name"]).to eq "foo\u{ff5e}bar"
      end

      it "converts NO-BREAK SPACE (U+00A0) to SPACE (U+0020)" do
        record.receiver_name = "foo\u{00a0}bar"
        expect(decoded.each.first["receiver_name"]).to eq "foo\u{0020}bar"
      end

      it "converts 𠷡 (U+20DE1) to 百合" do
        record.receiver_name = "𠷡野"
        expect(decoded.each.first["receiver_name"]).to eq "百合野"
      end

      it "converts 𠮷 (U+20BB7) to 吉" do
        record.receiver_name = "𠮷田"
        expect(decoded.each.first["receiver_name"]).to eq "吉田"
      end

      it "converts 繫 (U+7E6B) to 繋 (U+7E4B)" do
        record.receiver_name = "繫幸"
        expect(decoded.each.first["receiver_name"]).to eq "繋幸"
      end

      it "converts 䑓 (U+4453) to 臺 (U+81FA)" do
        record.receiver_name = "中䑓"
        expect(decoded.each.first["receiver_name"]).to eq "中臺"
      end
    end
  end
end
