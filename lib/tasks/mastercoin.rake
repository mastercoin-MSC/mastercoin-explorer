namespace :mastercoin do
  task :check_for_invalid => :environment do 
    Rails.application.eager_load!
    SimpleSend.valid.each do |transaction|
      transaction.check_transaction_validity
    end
  end

  task :parse_exodus => :environment do 
    Rails.application.eager_load!
    store = Mastercoin.storage
    txouts = store.get_txouts_for_address(Mastercoin::EXODUS_ADDRESS)
    puts "Parsing #{txouts.length} Exodus outputs"
    txouts.each do |txout|
      stime = Time.now
      transaction = txout.get_tx
      position = store.get_idx_from_tx_hash(transaction.hash)
      height = transaction.get_block.depth
      time = store.get_block_by_tx(transaction.hash).time
      puts "Checking transaction #{transaction.hash} to Exodus."
      begin
        tx = Mastercoin::Transaction.new(transaction.hash)
        puts "This is a Mastercoin transaction, do something"
        if tx.transaction_type.to_s == Mastercoin::TRANSACTION_SIMPLE_SEND
          unless SimpleSend.find_by(tx_id: transaction.hash).present?
            unless a = SimpleSend.create(is_exodus: false, block_height: height, position: position, multi_sig: tx.multisig, address: tx.source_address, block_height: transaction.blk_id, receiving_address: tx.target_address, transaction_type: tx.transaction_type, currency_id: tx.currency_id, tx_id: transaction.hash, amount: tx.amount / 1e8, tx_date: Time.at(time))
              raise "could not save: #{a.inspect}"
            end
          else
            puts "Mastercoin transaction already present."
          end
        else
          raise "We don't know this shit #{transaction.inspect}"
        end
      rescue Mastercoin::Transaction::NoMastercoinTransaction
        puts "Does not look like a mastercoin transaction. Must be exodus payment"
      ensure
        if ExodusTransaction.find_by(tx_id: transaction.hash).present?
          puts "Already have this tx. skipping"
        else
          info = Mastercoin::ExodusPayment.from_transaction(transaction.hash)
          if info.coins_bought.to_f > 0
            a = ExodusTransaction.create(address: Mastercoin::EXODUS_ADDRESS, position: position, block_height: height, receiving_address: info.address, transaction_type: -1, currency_id: 1, tx_id: info.tx.hash, amount: info.total_amount, bonus_amount_included: info.bonus_bought, is_exodus: true, tx_date: Time.at(info.time_included.to_i))
            ExodusTransaction.create(address: Mastercoin::EXODUS_ADDRESS, position: position, block_height: height, receiving_address: info.address, transaction_type: -1, currency_id: 2, tx_id: info.tx.hash, amount: info.total_amount, bonus_amount_included: info.bonus_bought, is_exodus: true, tx_date: Time.at(info.time_included.to_i))
            puts "Added transaction #{a.id} #{a.tx_date}"
          end
        end #end if/else
      end #end being rescu
      puts Time.now - stime
    end
  end
end

