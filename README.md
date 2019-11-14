# YamatoB2Cloud

CSV generator for [Kuroneko Yamato B2 Cloud](http://www.kuronekoyamato.co.jp/ytc/business/send/services/b2web/). CSV format specification is available at https://bmypage.kuronekoyamato.co.jp/bmypage/pdf/new_exchange1.pdf

## Installation

Add this line to your application's Gemfile:

```ruby
gem "yamato_b2_cloud", git: "https://github.com/laboho/yamato_b2_cloud.git"
gem "phonenumber", git: "https://github.com/labocho/phonenumber.git"
```

And then execute:

    $ bundle

## Example

```ruby
require "yamato_b2_cloud"
require "csv"

csv = CSV.new($stdout)

record = YamatoB2Cloud::Record.new(
  type: YamatoB2Cloud::Record::TYPE.COLLECT,
  shipping_date: Date.new(2019, 11, 13),
  delivery_date: Date.new(2019, 11, 14),
  delivery_time: YamatoB2Cloud::Record::DELIVERY_TIME.FROM_08_TO_12,
  receiver_phone_number: "08011112222",
  receiver_postal_code: "0000000",
  receiver_line_1: "送り先住所1",
  receiver_line_2: "送り先住所2",
  receiver_name: "送り先名前",
  sender_phone_number: "0311112222",
  sender_postal_code: "0000000",
  sender_line_1: "依頼主住所1",
  sender_line_2: "依頼主住所2",
  sender_name: "依頼主名前",
  description: "品名",
  billing_customer_code: "0311112222",
  shipping_fee_management_number: "01",
  collect_amount_within_tax: 12345,
  collect_amount_tax: 123,
)

csv << record.to_a
```

Prints...

```csv
,2,,,2019/11/13,2019/11/14,0812,,080-1111-2222,,000-0000,送り先住所1,送り先住所2,,,送り先名前,,,,03-1111-2222,,000-0000,依頼主住所1,依頼主住所2,依頼主名前,,,品名,,,,,,12345,123,,,,,0311112222,,01
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/labocho/yamato_b2_cloud.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
