class Transaction
  include Mongoid::Document

  field :an,  as: :account_name,      type: String
  field :au,  as: :account_number,    type: String
  field :am,  as: :amount,            type: Float
  field :bl,  as: :balance,           type: Float
  field :cc,  as: :currency_code,     type: String
  field :tt,  as: :transaction_type,  type: String
  field :cn,  as: :category_name,     type: String
  field :de,  as: :description,       type: String
  field :pd,  as: :post_date,         type: Date
  field :it,  as: :item_id,           type: Integer
  field :dm,  as: :dump,              type: Hash

  belongs_to :user

  def amount_formatted
    if self.transaction_type == 'credit'
      return self.amount
    else
      return (-1 * self.amount)
    end
  end

end
