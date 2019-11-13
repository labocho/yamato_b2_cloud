require "date"
require "active_model"
require "phonenumber"
require "yamato_b2_cloud/enum"

module YamatoB2Cloud
  class Record
    TYPE = Enum.new(
      PREPAID: 0,
      COLLECT: 2,
    )

    # 下記資料での "No."。-1 した値が CSV での index になる。
    # B2 クラウド 送り状発行データレイアウト 入出力用
    # https://bmypage.kuronekoyamato.co.jp/bmypage/pdf/new_exchange1.pdf
    ATTRIBUTE_NUMBERS = {
      type: 2,
      shipping_date: 5,
      receiver_phone_number: 9,
      receiver_postal_code: 11,
      receiver_address: 12,
      receiver_name: 16,
      sender_phone_number: 20,
      sender_postal_code: 22,
      sender_address: 23,
      sender_name: 25,
      description: 28,
      billing_customer_code: 40,
      shipping_fee_management_number: 42,
    }.freeze

    ATTRUBUTES = ATTRIBUTE_NUMBERS.keys.freeze

    include ::ActiveModel::Validations

    attr_accessor(*ATTRUBUTES)
    validates :type, presence: true
    validates :shipping_date, presence: true
    validates :receiver_phone_number, :sender_phone_number, presence: true, format: /\A(\d{10,12})\z/
    validates :receiver_postal_code, :sender_postal_code, presence: true, format: /\A(\d{7})\z/
    validates :receiver_address, :sender_address, presence: true
    validates :receiver_name, :sender_name, presence: true
    validates :description, presence: true
    validates :billing_customer_code, presence: true, format: /\A(\d{10,12})\z/
    validates :shipping_fee_management_number, presence: true, format: /\A(\d{2})\z/
    validate :validate_type

    def self.headers
      @headers ||= ATTRIBUTE_NUMBERS.each_with_object([]) do |(attr, n), a|
        a[n - 1] = attr.to_s
      end
    end

    def initialize(attributes = {})
      attributes.each do |k, v|
        raise "Unknown attribute #{k.inspect}" unless ATTRUBUTES.include?(k)

        send("#{k}=", v)
      end
    end

    def to_a
      ATTRIBUTE_NUMBERS.each_with_object([]) do |(attr, number), a|
        v = send(attr)

        a[number - 1] = case attr
        when :type
          v.value.to_s
        when :shipping_date
          format_date(v)
        when :receiver_phone_number, :sender_phone_number
          Phonenumber.hyphenate(v)
        when :receiver_postal_code, :sender_postal_code
          format_postal_code(v)
        else
          v.to_s
        end
      end
    end

    private
    def format_date(date)
      date.strftime("%Y/%m/%d")
    end

    def format_postal_code(postal_code)
      "#{postal_code[0, 3]}-#{postal_code[3, 4]}"
    end

    # rubocop:disable Style/GuardClause
    def validate_type
      unless TYPE.include?(type)
        errors.add(:type, :invalid)
      end

      unless shipping_date.is_a?(Date)
        errors.add(:shipping_date, :invalid)
      end
    end
    # rubocop:enable Style/GuardClause
  end
end
