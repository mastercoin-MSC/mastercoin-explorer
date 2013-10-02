class AddressesController < ApplicationController
  def show
    @address = Address.new(params[:id])
    @exodus_payments = ExodusTransaction.where(receiving_address: params[:id]).order("tx_date DESC")
    @received_payments = SimpleSend.where(receiving_address: params[:id]).order("tx_date DESC")
    @sent = SimpleSend.where(address: params[:id]).order("tx_date DESC")
  end
end
