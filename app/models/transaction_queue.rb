class TransactionQueue < ActiveRecord::Base
  validates :tx_hash, presence: true, uniqueness: true
  validates :json_payload, presence: true
end
