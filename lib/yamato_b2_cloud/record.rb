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

    DELIVERY_TIME = Enum.new(
      FROM_08_TO_12: "0812",
      FROM_14_TO_16: "1416",
      FROM_16_TO_18: "1618",
      FROM_18_TO_20: "1820",
      FROM_19_TO_21: "1921",
    )

    PRINT_NUMBER_OF_BOXES_FRAME = Enum.new(
      FRAME: 1,
      NONE: 2,
      FRAME_AND_NUMBER: 3,
    )

    # 下記資料での "No."。-1 した値が CSV での index になる。
    # B2 クラウド 送り状発行データレイアウト 入出力用
    # https://bmypage.kuronekoyamato.co.jp/bmypage/pdf/new_exchange1.pdf
    ATTRIBUTE_NUMBERS = {
      type: 2,
      shipping_date: 5,
      delivery_date: 6,
      delivery_time: 7,
      receiver_phone_number: 9,
      receiver_postal_code: 11,
      receiver_line_1: 12,
      receiver_line_2: 13,
      receiver_name: 16,
      sender_phone_number: 20,
      sender_postal_code: 22,
      sender_line_1: 23,
      sender_line_2: 24,
      sender_name: 25,
      description: 28,
      print_number_of_boxes_frame: 39,
      billing_customer_code: 40,
      shipping_fee_management_number: 42,
      note_to_deliverer: 33,
      collect_amount_within_tax: 34,
      collect_amount_tax: 35,
      search_key_title_1: 75,
      search_key_1: 76,
      search_key_title_2: 77,
      search_key_2: 78,
      search_key_title_3: 79,
      search_key_3: 80,
      search_key_title_4: 81,
      search_key_4: 82,
      search_key_title_5: 83,
      search_key_5: 84,
    }.freeze

    ATTRUBUTES = ATTRIBUTE_NUMBERS.keys.freeze

    include ::ActiveModel::Validations

    attr_accessor(*ATTRUBUTES)
    validates :type, presence: true
    validates :shipping_date, presence: true
    validates :receiver_phone_number, :sender_phone_number, presence: true, format: /\A(\d{10,12})\z/
    validates :receiver_postal_code, :sender_postal_code, presence: true, format: /\A(\d{7})\z/
    validates :receiver_line_1, :sender_line_1, presence: true
    validates :receiver_name, :sender_name, presence: true
    validates :description, presence: true
    validates :billing_customer_code, presence: true, format: /\A(\d{10,12})\z/
    validates :shipping_fee_management_number, presence: true, format: /\A(\d{2})\z/
    validate :validate_type
    validate :validate_collect_amount

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
      unless valid?
        raise "Cannot convert invalid record to array: #{inspect}\n#{errors.full_messages}"
      end

      ATTRIBUTE_NUMBERS.each_with_object([]) do |(attr, number), a|
        v = send(attr)

        if v.nil?
          a[number - 1] = nil
          next
        end

        a[number - 1] = case attr
        when :type, :delivery_time, :print_number_of_boxes_frame
          v.value.to_s
        when :shipping_date, :delivery_date
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

      unless delivery_time.nil? || DELIVERY_TIME.include?(delivery_time)
        errors.add(:delivery_time, :invalid)
      end

      unless shipping_date.is_a?(Date)
        errors.add(:shipping_date, :invalid)
      end

      unless delivery_date.nil? || delivery_date.is_a?(Date)
        errors.add(:delivery_date, :invalid)
      end
    end
    # rubocop:enable Style/GuardClause

    def validate_collect_amount
      if type == TYPE.COLLECT
        unless collect_amount_within_tax.is_a?(Integer) && collect_amount_within_tax > 0
          errors.add(:collect_amount_within_tax, :invalid)
        end

        unless collect_amount_tax.is_a?(Integer) && collect_amount_tax > 0
          errors.add(:collect_amount_tax, :invalid)
        end
      else
        unless collect_amount_within_tax.nil?
          errors.add(:collect_amount_within_tax, :invalid)
        end

        unless collect_amount_tax.nil?
          errors.add(:collect_amount_tax, :invalid)
        end
      end
    end
  end
end
