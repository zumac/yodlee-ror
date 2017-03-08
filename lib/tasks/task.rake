task :rand_transaction_data => :environment do
  Transaction.all.each do | transaction |
      transaction.post_date = (DateTime.now - rand(360).to_i.days).beginning_of_day
      transaction.save
  end
end