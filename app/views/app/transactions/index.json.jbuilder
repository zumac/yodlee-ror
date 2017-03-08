json.status 'true'
json.bank do
  json.array! @account do | account |
    json.account account.item_account_id
    json.image @bank.select{|m| m.id.to_s == account.bank_id.to_s}.first.image
  end
end
json.transactions do
  json.array! @transactions do | transaction |
    json.account_id transaction.item_id.to_s
    json.post_date transaction.post_date
    json.category_name transaction.category_name
    json.description transaction.description
    json.transaction_type transaction.transaction_type
    if transaction.transaction_type == 'credit'
      json.amount '%.2f' % transaction.amount
    else
      json.amount '%.2f' % (-1 * transaction.amount)
    end
  end
end
