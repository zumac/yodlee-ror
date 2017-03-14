class Admin::TransactionsController < Admin::AdminApplicationController

  def index
    @transactions = Transaction.all.sort(:post_date => -1)
    @account = Account.in(:item_account_id => @transactions.map{|m| m.item_id}.uniq)
    @bank = Bank.find(@account.map{|m| m.bank_id}.uniq)
    @user = User.where(:id.in => @transactions.map{|m| m.user_id})
  end

  def csv
    @transactions = Transaction.all
    @account = Account.in(:item_account_id => @transactions.map{|m| m.item_id}.uniq)
    @bank = Bank.find(@account.map{|m| m.bank_id}.uniq)
    @user = User.where(:id.in => @transactions.map{|m| m.user_id})
    headers = make_one_dimensional(@transactions.first.dump).keys
    CSV.open("data.csv", "wb") do |csv|
      csv << headers # adds the attributes name on the first line
      @transactions.each do |hash|
        csv << headers.map{|m| make_one_dimensional(hash.dump)[m] }
      end
    end
    csv_data = File.read('data.csv')
    send_data(csv_data, :type => 'application/csv', :filename => "data.csv", :x_sendfile => true)
  end

  def make_one_dimensional(input = {}, output = {}, prefix = nil)
    if input.respond_to?(:each)
      input.each do |key, value|
        key = [prefix, key].compact.join('.')
        case value
          when Hash
            make_one_dimensional(value, output, key)
          when Array
            value.each_with_index do |v, index|
              array_key = "#{key}[#{index}]"
              make_one_dimensional(v, output, array_key)
            end
          else
            output[key] = value
        end
      end
    else
      output[prefix] = input
    end
    output
  end

end