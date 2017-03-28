== README

1. First Create a user

2. Second Login into yodlee account ( Yodlee Cred in user.rb)

    user = User.first.yodlee.login

3. Select a Bank

4. Get Login Requirements for that bank using

    bank.yodlee.login_requirements

5. Create a Account

    account = Account.new(user: user, bank: bank)

    where user and bank and respective objects

6. Create a Account with Yodlee

    account.yodlee.create({"LOGIN" => "ronakjain90.bank2", "PASSWORD1" => "bank2"})

    This may take sometime

7. Refresh the Account - Tell Yodlee to sync data from Bank Website

    account.yodlee.refresh

8. Ping Yodlee to know if refresh is successful and done

   account.yodlee.ping

   This will hit every 2 seconds, and will return true once done

9. Get Transaction data into local database.

   account.yodlee.get_transaction_data

   Next time you hit this API, it'll automatically get the lastest transaction from the last refresh

