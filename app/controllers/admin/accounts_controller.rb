class Admin::AccountsController < Admin::AdminApplicationController

  def status
    @accounts = Account.all
    @bank = Bank.find(@accounts.map{|m| m.bank_id}.uniq)
    @user = User.where(:id.in => @accounts.map{|m| m.user_id})
  end

end