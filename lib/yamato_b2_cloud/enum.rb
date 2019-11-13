module YamatoB2Cloud
  class Enum
    class Value
      attr_reader :name, :value

      def initialize(name, value)
        raise "Value name must be Symbol" unless name.is_a?(Symbol)

        @name = name
        @value = value.freeze
      end
    end

    def initialize(values)
      @values = values.each_with_object({}) {|(name, value), h|
        h[name] = Value.new(name, value)
      }.freeze

      @values.each do |k, v|
        define_value_reader(k, v)
      end
    end

    def include?(value)
      @values.values.include?(value)
    end

    private
    def define_value_reader(name, value)
      define_singleton_method(name) do
        value
      end
    end
  end
end
