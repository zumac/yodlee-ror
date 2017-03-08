json.status 'true'
json.bank do
  json.array! @accounts do | account |
    bank = @banks.select{|m| m.id.to_s == account.bank_id.to_s}.first
    json.id bank.id.to_s
    json.name bank.site_display_name
    json.image bank.image
    json.account_id account.yodlee_id.to_s
    json.status_code account.status_code
    json.message Account::Error[account.status_code]
  end
end