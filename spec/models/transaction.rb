require "spec_helper"

describe Transaction do
  context "Checking for valid transactions" do
    it "should be able to flag a transaction as valid when bought via Exodus" do
      FactoryGirl.create(:exodus_transaction)
      tx = FactoryGirl.create(:simple_send)
      tx.invalid_tx.should == false
    end

    it "should not double spend transactions and only allow the payment once" do
      FactoryGirl.create(:exodus_transaction)

      tx = FactoryGirl.create(:simple_send)
      tx.invalid_tx.should == false

      tx2 = FactoryGirl.build(:simple_send)
      tx2.position = 8
      tx2.save
      tx2.invalid_tx.should == true
    end

    it "should not double spend transactions but if funds are received in block it can use those" do
      FactoryGirl.create(:exodus_transaction)
      a = FactoryGirl.build(:exodus_transaction)
      a.receiving_address = "ASDASD!@DJ!*(@DJ*(!@DJ*(D"
      a.save

      tx = FactoryGirl.create(:simple_send)
      tx.invalid_tx.should == false

      tx2 = FactoryGirl.build(:simple_send)
      tx2.position = 8
      tx2.save

      tx3 = FactoryGirl.build(:simple_send)
      tx3.receiving_address = tx2.address
      tx3.position = 9
      tx3.address = a.receiving_address
      tx3.save

      tx4 = FactoryGirl.build(:simple_send)
      tx4.position = 15
      tx4.save

      tx2.invalid_tx.should == true
      tx3.invalid_tx.should == false
      tx4.invalid_tx.should == false
    end

    it "should not be valid if a payment was send without any funds from exodus" do
      tx = FactoryGirl.create(:simple_send)
      tx.invalid_tx.should == true
    end

    it "should not be valid if a payment was send when the exodus payment was received later" do
      exodus = FactoryGirl.build(:exodus_transaction)
      tx = FactoryGirl.create(:simple_send)
      exodus.tx_date = tx.tx_date + 2.hours
      exodus.save
      
      tx.invalid_tx.should == true
    end

    it "should accept a payment after exodus transaction but ignore the one before exodus transaction" do
      exodus = FactoryGirl.build(:exodus_transaction)
      tx = FactoryGirl.create(:simple_send)
      exodus.tx_date = tx.tx_date + 2.hours
      exodus.save
      tx.invalid_tx.should == true

      tx2 = FactoryGirl.build(:simple_send)
      tx2.tx_date = exodus.tx_date + 1.hour
      tx2.save
      tx2.invalid_tx.should == false
    end
  end
end
