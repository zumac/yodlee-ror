class App::AccountsController < ApplicationController

  before_action :authenticate_user!

  def index
    puts current_user.id
    @accounts = Account.where(:user_id => current_user.id)
    @banks = Bank.find(@accounts.map{|m| m.bank_id}.compact.uniq)
    render 'app/accounts/index.json'
  end

  def refresh
    current_user.yodlee.login
    account = Account.where(:user_id => current_user.id, :yodlee_id => params[:id].to_i).first
    account.yodlee.refresh
    render json: { status: true }
  end

  def refresh_all
    current_user.yodlee.login
    accounts = Account.where(:user_id => current_user.id)
    accounts.each do | account |
      account.yodlee.refresh
    end
    render json: { status: true }
  end

  def delete
    begin
      current_user.yodlee.login
      account = Account.where(:user_id => current_user.id, :yodlee_id => params[:id].to_i).first
      account.yodlee.remove
      if account.item_account_id.present?
        transactions = Transaction.where(:user_id => current_user.id, :item_id.in => account.item_account_id)
        if transactions.present?
          transactions.each do | transaction |
            transaction.delete
          end
        end
      end
      account.delete
      Rails.cache.delete "#{current_user.id}-transactions"
      Rails.cache.delete "#{current_user.id}-balance"
      @accounts = Account.where(:user_id => current_user.id)
      @banks = Bank.find(@accounts.map{|m| m.bank_id}.uniq)
      render 'app/accounts/index'
    rescue Exception => e
      render json: {
                 status: :false,
                 error: {
                     code: 500,
                     message: 'Yodlee SSL Connection Time out'
                 }
             }

    end
  end

end
