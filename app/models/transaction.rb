class Transaction < ActiveRecord::Base
  CURRENCIES = {
    1 => "Mastercoin",
    2 => "Test Mastercoin",
  }

  scope :real, -> { where(currency_id: 1) }
  scope :test, -> { where(currency_id: 2) }
  scope :valid, -> { where(invalid_tx: false) }

  def as_json(options = {})
    options.reverse_merge!({except: [:id, :is_exodus]})
    super
  end

  def currency
    Transaction::CURRENCIES[self.currency_id]
  end

  def mark_invalid!
    self.update_attribute(:invalid_tx, true)
  end
end
