class Transaction
  include Mongoid::Document

  field :an,  as: :account_name,      type: String
  field :au,  as: :account_number,    type: String
  field :am,  as: :amount,            type: Float
  field :bl,  as: :balance,           type: Float
  field :cc,  as: :currency_code,     type: String
  field :tt,  as: :transaction_type,  type: String
  field :cn,  as: :category_name,     type: String
  field :oc,  as: :original_category_name, type: String
  field :de,  as: :description,       type: String
  field :pd,  as: :post_date,         type: Date
  field :it,  as: :item_id,           type: Integer
  field :dm,  as: :dump,              type: Hash

  belongs_to :user

  TransactionCategories = [
    {
      id: 1,
      category_name: 'Uncategorized',
      category_type: 'Uncategorize'
    },
    {
      id: 2,
      category_name: 'Automotive Expenses',
      category_type: 'Expense'
    },
    {
      id: 3,
      category_name: 'Charitable Giving',
      category_type: 'Expense'
    },
    {
      id: 4,
      category_name: 'Child/Dependent Expenses',
      category_type: 'Expense'
    },
    {
      id: 5,
      category_name: 'Clothing/Shoes',
      category_type: 'Expense'
    },
    {
      id: 6,
      category_name: 'Education',
      category_type: 'Expense'
    },
    {
      id: 7,
      category_name: 'Entertainment',
      category_type: 'Expense'
    },
    {
      id: 8,
      category_name: 'Gasoline/Fuel',
      category_type: 'Expense'
    },
    {
      id: 9,
      category_name: 'Gifts',
      category_type: 'Expense'
    },
    {
      id: 10,
      category_name: ' Groceries',
      category_type: 'Expense'
    },
    {
      id: 11,
      category_name: 'Healthcare/Medical',
      category_type: 'Expense'
    },
    {
      id: 12,
      category_name: 'Home Maintenance',
      category_type: 'Expense'
    },
    {
      id: 13,
      category_name: 'Home Improvement',
      category_type: 'Expense'
    },
    {
      id: 14,
      category_name: 'Insurance',
      category_type: 'Expense'
    },
    {
      id: 15,
      category_name: 'Cable/Satellite Services',
      category_type: 'Expense'
    },
    {
      id: 16,
      category_name: 'Online Services',
      category_type: 'Expense'
    },
    {
      id: 17,
      category_name: ' Loans',
      category_type: 'Expense'
    },
    {
      id: 18,
      category_name: 'Mortgages',
      category_type: 'Expense'
    },
    {
      id: 19,
      category_name: 'Other Expenses',
      category_type: 'Expense'
    },
    {
      id: 20,
      category_name: 'Personal Care',
      category_type: 'Expense'
    },
    {
      id: 21,
      category_name: 'Rent',
      category_type: 'Expense'
    },
    {
      id: 22,
      category_name: 'Restaurants/Dining',
      category_type: 'Expense'
    },
    {
      id: 23,
      category_name: 'Travel',
      category_type: 'Expense'
    },
    {
      id: 24,
      category_name: 'Service Charges/Fees',
      category_type: 'Expense'
    },
    {
      id: 25,
      category_name: 'ATM/Cash Withdrawals',
      category_type: 'Expense'
    },
    {
      id: 26,
      category_name: 'Credit Card Payments',
      category_type: 'Transfer'
    },
    {
      id: 27,
      category_name: 'Deposits',
      category_type: 'Income'
    },
    {
      id: 28,
      category_name: 'Transfers',
      category_type: 'Transfer'
    },
    {
      id: 29,
      category_name: 'Paychecks/Salary',
      category_type: 'Income'
    },
    {
      id: 30,
      category_name: 'Investment Income',
      category_type: 'Income'
    },
    {
      id: 31,
      category_name: 'Retirement Income',
      category_type: 'Income'
    },
    {
      id: 32,
      category_name: 'Other Income',
      category_type: 'Income'
    },
    {
      id: 33,
      category_name: 'Checks',
      category_type: 'Expense'
    },
    {
      id: 34,
      category_name: 'Hobbies',
      category_type: 'Expense'
    },
    {
      id: 35,
      category_name: 'Other Bills',
      category_type: 'Expense'
    },
    {
      id: 36,
      category_name: 'Securities Trades',
      category_type: 'Transfer'
    },
    {
      id: 37,
      category_name: 'Taxes',
      category_type: 'Expense'
    },
    {
      id: 38,
      category_name: 'Telephone Services',
      category_type:  'Expense'
    },
    {
      id: 39,
      category_name: 'Utilities',
      category_type: 'Expense'
    },
    {
      id: 40,
      category_name: 'Savings',
      category_type: 'Transfer'
    },
    {
      id: 41, 
      category_name: 'Retirement Contributions',
      cateogry_type: 'Deferred Compensation'
    },
    {
      id: 42, 
      category_name: 'Pets/Pet Care',
      cateogry_type: 'Expense'
    },
    {
      id: 43, 
      category_name: 'Electronics',
      category_type: 'Expense'
    },
    {
      id: 44, 
      category_name: 'General Merchandise',
      category_type: 'Expense'
    },
    {
      id: 45, 
      category_name: 'Office Supplies',
      category_type: 'Expense'
    },
    {
      id: 92, 
      category_name: 'Consulting',
      category_type: 'Income'
    },
    {
      id: 94, 
      category_name: 'Sales',
      category_type: 'Income'
    },
    {
      id: 96, 
      category_name: 'Interest',
      category_type: 'Income'
    },
    {
      id: 98, 
      category_name: 'Services',
      category_type: 'Income'
    },
    {
      id: 100,
      category_name: 'Advertising',
      category_type: 'Expense'
    },
    {
      id: 102,
      category_name: 'Business Miscellaneous',
      category_type: 'Expense'
    },
    {
      id: 104,
      category_name: 'Postage and Shipping',
      category_type: 'Expense'
    },
    {
      id: 106,
      category_name: 'Printing',
      category_type: 'Expense'
    },
    {
      id: 108,
      category_name: 'Dues and Subscriptions',
      category_type: 'Expense'
    },
    {
      id: 110,
      category_name: 'Office Maintenance',
      category_type: 'Expense'
    },
    {
      id: 112,
      category_name: 'Wages Paid',
      category_type: 'Expense'
    },
    {
      id: 114,
      category_name: 'Expense Reimbursement',
      category_type:'Income'
    }
  ]
  def amount_formatted
    if self.transaction_type == 'credit'
      return self.amount
    else
      return (-1 * self.amount)
    end
  end

  def self.categories
    Transaction::TransactionCategories
  end
  # def self.categories(user_id = nil)
  #   map = %Q{
  #     function() {
  #       emit(this.cn, {category_name: this.cn})
  #     }
  #   }

  #   reduce = %Q{
  #     function(key, values) {
  #       return {category_name: key};
  #     }
  #   }
  #   if user_id
  #     cats = self.where(user_id: user_id).map_reduce(map, reduce).out(inline: true)
  #   else
  #     cats = self.map_reduce(map, reduce).out(inline: true)
  #   end
  #   cats
  # end

end
