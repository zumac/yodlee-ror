json.status 'true'
json.banks do
  json.array! @banks do | bank |
    popular = @popular_banks.any? { |word| bank.csdn.to_s.include?(word) }
    json.co bank.co.to_s
    json.csdn bank.csdn.to_s
    json.csi bank.csi
    json.hu bank.hu.to_s
    json.img bank.img
    json.mfa bank.mfa
    json.sdn bank.sdn
    json.si bank.si
    json.id bank.id.to_s
    json.popular popular
  end
end