class TransactionsController < ApplicationController
  def show
    @transaction = Transaction.where(tx_id: params[:id]).first
    unless @transaction
      redirect_to root_path, notice: "Could not find transaction with transaction id #{params[:id]}"
    end
  end

  def index
    @transactions = Transaction.where(invalid_tx: true)
  end
end
