class App::TransactionsController < ApplicationController

  before_action :authenticate_user!

  def index
    accounts = Account.where(:user_id => current_user.id)
    if accounts.count == 0
      render json: {
                 status: :false,
             }
    else
      Rails.cache.fetch "#{current_user.id}-transactions", :expires_in => 1.minute do
        Rails.logger.info 'REFRESHING THE API'
        current_user.yodlee.login
        accounts.each do |account|
          puts '------------', account.id
          account.yodlee.get_transaction_data
        end
        current_user.id
      end

      @transactions = Transaction.where(:user_id => current_user.id)
      
      if params[:last_id].present?
         @transactions = @transactions.where(:_id.gt => (params[:last_id]).to_i)
      else
        if params[:to].present?
          to = params[:to].to_date
          @transactions = @transactions.where(:post_date.lte => to)
        else
          to = Date.today
        end
        if params[:days].present?
          from = (to - params[:days].to_i.days)
          @transactions = @transactions.where(:post_date.gt => from)
        end
      end

      @account = Account.in(:item_account_id => @transactions.map{|m| m.item_id}.uniq)
      @bank = Bank.find(@account.map{|m| m.bank_id}.uniq)
      render 'app/transactions/index.json'
    end
  end

  def query
    accounts = Account.where(:user_id => current_user.id)
    Rails.cache.fetch "#{current_user.id}-transactions", :expires_in =>30.minutes do
      current_user.yodlee.login
      accounts.first.yodlee.get_transaction_data
      current_user.id
    end
    @transactions = Transaction.where(:user_id => current_user.id)
    if params[:days].present?
      from = (Date.today - params[:days].to_i.days)
      @transactions = @transactions.where(:user_id => current_user.id, :post_date.gt => from)
    end

    if params[:category_name].present?
      @transactions = @transactions.where(:user_id => current_user.id, :cn => params[:category_name])
    end

    if params[:transaction_type].present?
      @transactions = @transactions.where(:user_id => current_user.id, :tt => params[:transaction_type])
    end

    @account = Account.in(:item_account_id => @transactions.map{|m| m.item_id}.uniq)
    @bank = Bank.find(@account.map{|m| m.bank_id}.uniq)
    render 'app/transactions/index.json'
  end

  def dashboard
    
    statistics, debit_chart, credit_chart = {credit: {}, debit: {}, chart: [] }, {}, {}
    transactions = Transaction.where(:user_id => current_user.id)

    to = params[:to].present? ? params[:to].to_date : Date.today
    if params[:to].present?
      transactions = transactions.and(:post_date.lte => to)
    end

    if params[:days].present? 
      from = (to - params[:days].to_i.days)
      transactions = transactions.and(:post_date.gt => from)
    else
      from = Transaction.where(:user_id => current_user.id).min(:post_date).to_date
    end

    transactions = transactions.to_a

    accounts = Account.where(:user_id => current_user.id).to_a
    if accounts.count == 0
      render json: {
           status: :false,
       }
    else
      all_accounts = accounts.map{|m| m.item_account_id}.flatten

      start_balance_of_item_ids = {}
      all_accounts.each do | item_id |
        transactions_for_item_id = transactions.select{|m| m.item_id == item_id}
        if transactions_for_item_id.count > 0
          balance = initial_balance_for_item_id(accounts, item_id)
          amount = balance - transactions_for_item_id.map{|m| m.amount_formatted}.inject(:+)
          start_balance_of_item_ids.merge!(item_id => amount)
        else
          start_balance_of_item_ids.merge!(item_id => initial_balance_for_item_id(accounts, item_id))
        end
      end

      date_from_yodlee_data_available = current_user.transaction_available_from_date

      (from..to).each do | date |
        if date < date_from_yodlee_data_available

        elsif date == date_from_yodlee_data_available
          statistics[:chart].push({date: date, amount: start_balance_of_item_ids.values.inject(:+)})
        else
          transaction_for_given_day = transactions.select{|m| (m.post_date == date.beginning_of_day)}
          all_accounts.each do | item_id |
            transaction_for_given_item_id = transaction_for_given_day.select{|m| m.item_id == item_id}
            credits = transaction_for_given_item_id.select{|m| m.transaction_type == 'credit'}.map{|m| m.amount}.inject(0){ |sum, i| sum + i }.round(2)
            debits = transaction_for_given_item_id.select{|m| m.transaction_type == 'debit'}.map{|m| m.amount}.inject(0){ |sum, i| sum + i }.round(2)
            start_balance_of_item_ids[item_id] = start_balance_of_item_ids[item_id] +  credits - debits
          end
          statistics[:chart].push({date: date, amount: start_balance_of_item_ids.values.inject(:+).round(2)})
        end
      end

      credits = transactions.select{|m| m.transaction_type == 'credit'}
      debits = transactions.select{|m| m.transaction_type == 'debit'}
      statistics[:credit][:total] = credits.map{|m| m.amount}.inject(0){ |sum, i| sum + i }.round(2)
      statistics[:credit][:count] = credits.count
      statistics[:credit][:average] = (statistics[:credit][:total] / statistics[:credit][:count]).round(2)
      statistics[:debit][:total] = debits.map{|m| m.amount}.inject(0){ |sum, i| sum + i }.round(2)
      statistics[:debit][:count] = debits.count
      statistics[:debit][:average] = (statistics[:debit][:total] / statistics[:debit][:count]).round(2)
      render json: {
                 status: true,
                 statistics: statistics
             }
    end

  end

  def balance
    transactions = Transaction.where(:user_id => current_user.id).to_a
    if transactions.count == 0
      render json: {
          status: false
        }
    else
      accounts = Account.where(:user_id => current_user.id).to_a
      all_accounts = accounts.map{|m| m.item_account_id}.flatten
      accounts_with_transactions = transactions.group_by{|m| m.item_id}.keys
      last_available_balance_for_accounts_with_transactions = []
      accounts_with_transactions.each do | item_id |
        transactions_of_account = transactions.select{|m| m.item_id == item_id}
        if transactions_of_account.first['dm']['viewKey']['containerType'] == 'credits'
          last_available_balance_for_accounts_with_transactions << initial_balance_for_item_id(accounts, item_id)
        else
          last_available_balance_for_accounts_with_transactions << transactions_of_account.last.balance
        end
      end
      accounts_without_transactions = all_accounts - accounts_with_transactions
      balance_of_accounts_without_transactions = 0
      accounts_without_transactions.each do | item_id |
        balance_of_accounts_without_transactions += initial_balance_for_item_id(accounts, item_id)
      end
      balance = (last_available_balance_for_accounts_with_transactions.inject(:+) + balance_of_accounts_without_transactions).round(2)
      balance

      render json: {
                 status: true,
                 balance: balance
             }
    end
  end

  def categories
    render json: {
      status: true,
      categories: Transaction.categories
    }
  end

  def change_category
    if params[:id].present? && params[:category_name].present?
      transaction = Transaction.where(id: params[:id]).first
      if transaction.present?
        transaction.update_attributes!(category_name: params[:category_name])
        render json: {
          status: true,
        }
        return
      end
    end
    render json: {
      status: false,
    }
  end

  def initial_balance_for_item_id(accounts, item_id)
    account = accounts.select{|m| m.available_balance.has_key?(item_id.to_s)}.first
    if account.present?
      account.available_balance[item_id.to_s]
    else
      return 0
    end
  end

end
