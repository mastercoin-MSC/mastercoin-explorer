FactoryGirl.define do
  factory :exodus_transaction do
    address "1EXoDusjGwvnjZUyKkxZ4UHEf77z6A5S4P"
    receiving_address "1KA9SV5pyqpW3sqZbfAWhSRiVeeN552BXQ"
    transaction_type -1
    currency_id 1
    is_exodus true
    amount 10
    bonus_amount_included 1
    tx_date "2013-08-01 22:39:30"
    block_height 4
  end

  # This will use the User class (Admin would have been guessed)
  factory :simple_send do
    address "1KA9SV5pyqpW3sqZbfAWhSRiVeeN552BXQ"
    receiving_address "1Cu3gkevrm5bAJAWabwiWMWw8DsVujDbMD"
    transaction_type 0
    currency_id 1
    amount 10
    tx_date "2013-08-01 23:39:30"
    block_height 5
    position 5
  end
end
