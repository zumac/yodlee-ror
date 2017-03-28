json.status 'true'
json.bank do
  json.array! @accounts do | account |
    bank = @banks.select{|m| m.id.to_s == account.bank_id.to_s}.first
    next if bank.nil?
    json.id bank.id.to_s
    json.name bank.site_display_name
    json.image bank.image
    json.account_id account.yodlee_id.to_s
    json.status_code account.status_code
    json.available_balance account.available_balance
    json.acc_type account.acc_type
    json.updated_at account.updated_at.to_date
    json.message Account::Error[account.status_code]
    json.site_id bank.si
    json.csi bank.csi
  end
end