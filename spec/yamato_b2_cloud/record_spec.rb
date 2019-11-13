require "spec_helper"

module YamatoB2Cloud
  RSpec.describe Record do
    let(:record) {
      Record.new(
        type: Record::TYPE.COLLECT,
        shipping_date: Date.new(2019, 11, 13),
        receiver_phone_number: "08012345678",
        receiver_postal_code: "1234567",
        receiver_address: "送り先住所",
        receiver_name: "送り先名前",
        sender_phone_number: "0591112222",
        sender_postal_code: "2345678",
        sender_address: "依頼主住所",
        sender_name: "依頼主名前",
        description: "品名",
        billing_customer_code: "0592223333",
        shipping_fee_management_number: "01",
      )
    }

    describe "validation" do
      subject { record }
      it { should be_valid }

      describe "type" do
        it "accept only TYPE::*" do
          record.type = nil
          should_not be_valid

          record.type = 20
          should_not be_valid

          record.type = Record::TYPE.PREPAID
          should be_valid
        end
      end

      describe "shipping_date" do
        it "accept only Date" do
          record.shipping_date = nil
          should_not be_valid

          record.shipping_date = "2019/11/13"
          should_not be_valid

          record.shipping_date = Time.now
          should_not be_valid
        end
      end

      %i(
        receiver_phone_number
        receiver_postal_code
        receiver_address
        receiver_name
        sender_phone_number
        sender_postal_code
        sender_address
        sender_name
        description
        billing_customer_code
        shipping_fee_management_number
      ).each do |attribute|
        describe attribute do
          it "should be presence" do
            record.send("#{attribute}=", nil)
            should_not be_valid

            record.send("#{attribute}=", "")
            should_not be_valid
          end
        end
      end
    end

    describe ".headers" do
      subject { Record.headers }
      it "returns csv header" do
        should be_an Array
        expect(subject[1]).to eq "type"
      end
    end

    describe "to_a" do
      subject { record.to_a }
      it {
        should eq [
          nil,
          "2",
          nil,
          nil,
          "2019/11/13",
          nil,
          nil,
          nil,
          "080-1234-5678",
          nil,
          "123-4567",
          "送り先住所",
          nil,
          nil,
          nil,
          "送り先名前",
          nil,
          nil,
          nil,
          "059-111-2222",
          nil,
          "234-5678",
          "依頼主住所",
          nil,
          "依頼主名前",
          nil,
          nil,
          "品名",
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          "0592223333",
          nil,
          "01",
        ]
      }
    end
  end
end
