class Advisor
  include ActiveModel::Validations
  include ActiveModel::Model
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  attr_accessor :currency_id, :transaction_type, :amount, :receiving_address
  attr_accessor :advice_object

  validates :amount, numericality: {greater_than: 0}, presence: true
  validates :currency_id, presence: true
  validates :transaction_type, presence: true
  validates :receiving_address, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def advice!
    self.advice_object = Mastercoin::Advisor.new(self.currency_id.to_i, self.amount.to_f, self.transaction_type.to_i, self.receiving_address.to_s)
  end

  def persisted?
    false
  end
end
