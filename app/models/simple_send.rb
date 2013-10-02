class SimpleSend < Transaction
  # TODO: Add a function to check if the same block has multiple txes and use position to determine the winner
  # TODO: Create specs
  # 1. Check if funds were present at the time; ignore if not but make sure a next payment should work
  # 2. Check if multiple payments in the same block were made that would throw balance in the minus
  after_create :check_transaction_validity

  def bought_total
    bought = ExodusTransaction.where("tx_date <= ?", self.tx_date).valid.where(receiving_address: self.address).sum(:amount)
    bought += SimpleSend.where("tx_date <= ?", self.tx_date).valid.where(receiving_address: self.address).sum(:amount)
    return bought
  end

  def had_funds?
    bought = bought_total
    spend = SimpleSend.where("tx_date <= ?", self.tx_date).valid.where(address: self.address).sum(:amount)
    bought >= spend
  end

  def balance_before(date)
    bought = ExodusTransaction.where("tx_date < ?", date).valid.where(receiving_address: self.address).sum(:amount)
    bought += SimpleSend.where("tx_date < ?", date).valid.where(receiving_address: self.address).sum(:amount)
    spend = SimpleSend.where("tx_date < ?", self.tx_date).valid.where(address: self.address).sum(:amount)
    balance = bought - spend
    return balance
  end

  # 1. Check if there were multiple sends in this transactions
  # 2. Check to see if the money received before this transaction will cover everything
  # 3. If the balance before this transaction was not enough see if we received enough in this block
  def sibling_validations!
    outgoing = SimpleSend.where(block_height: self.block_height).where(address: self.address)

    current_balance = balance_before(self.tx_date)

    return if outgoing.empty?
    return if current_balance >= outgoing.sum(:amount)

    SimpleSend.where(block_height: self.block_height).where("address = ? OR receiving_address = ?", self.address, self.address).order("position ASC").each do |transaction|
      if transaction.address == self.address # sending this payment
        current_balance -= transaction.amount
        if current_balance < 0
          transaction.mark_invalid!
        end
      elsif transaction.receiving_address == self.address
        current_balance += transaction.amount
      end
    end
  end

  def check_transaction_validity
    unless self.had_funds?
      self.mark_invalid! 
    end
    self.sibling_validations!

    true
  end
end
