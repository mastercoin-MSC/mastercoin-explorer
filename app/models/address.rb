class Address
  attr_accessor :address, :sent_transactions, :received_transactions, :exodus_transactions, :received_via_exodus, :balance, :test_balance, :spendable_outputs, :bitcoin_transactions
  # TODO: Refactor class

  def initialize(address)
    self.address = address
  end

  def as_json(options = {})
    self.sent_transactions = self.sent(nil)
    self.received_transactions = self.received(nil)
    self.exodus_transactions = self.exodus_payments(nil)
    self.balance = balance()
    self.test_balance = balance(2)

    if options.has_key?(:include_outputs)
      self.spendable_outputs = []
      self.bitcoin_transactions  = []

      txouts = Mastercoin.storage.get_txouts_for_address(self.address)
      txouts.each do |txout|
        unless txout.get_next_in
          out_hash = txout.to_hash
          tx = txout.get_tx
          index = tx.outputs.index(txout)
          self.bitcoin_transactions << tx.to_hash unless self.bitcoin_transactions.include?(tx.to_hash)

          self.spendable_outputs << out_hash.merge(:"prev_out" => {:"hash" => tx.hash, :"n" => index})
        end
      end
    end

    super(options)
  end

  def exodus_payments(coin_id = 1)
    if coin_id.present?
      ExodusTransaction.where(receiving_address: self.address).order("tx_date DESC").where(currency_id: coin_id).valid
    else
      ExodusTransaction.where(receiving_address: self.address).order("tx_date DESC").valid
    end
  end

  def received(coin_id = 1)
    if coin_id.present?
      SimpleSend.where(receiving_address: self.address).order("tx_date DESC").where(currency_id: coin_id).valid
    else
      SimpleSend.where(receiving_address: self.address).order("tx_date DESC").valid
    end
  end

  def sent(coin_id = 1)
    if coin_id.present?
      SimpleSend.where(address: self.address).order("tx_date DESC").where(currency_id: coin_id).valid
    else
      SimpleSend.where(address: self.address).order("tx_date DESC").valid
    end
  end

  def balance(coin_id = 1)
    @exodus_payments = self.exodus_payments(coin_id)
    @simple_receive= self.received(coin_id)
    @simple_sent = sent(coin_id)

    rec = @simple_receive.sum(:amount)
    rec_via_exodus = @exodus_payments.sum(:amount)
    sent_amount = @simple_sent.sum(:amount)

    return rec + rec_via_exodus - sent_amount
  end
end
