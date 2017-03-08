require 'settings'

class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, #:confirmable,
         :recoverable, :rememberable, :trackable, :validatable,:trackable

  ## Database authenticatable
  field :first_name,              type: String, default: ""
  field :last_name,               type: String, default: ""
  field :email,                   type: String, default: ""
  field :encrypted_password,      type: String, default: ""
  field :gender,                  type: String, default: ""
  field :phone,                   type: String, default: ""
  field :postal_code,             type: String, default: ""
  field :dob,                     type: Date

  ## Recoverable
  field :reset_password_token,    type: String
  field :reset_password_sent_at,  type: Time

  ## Rememberable
  field :remember_created_at,     type: Time

  ## Trackable
  field :sign_in_count,           type: Integer, default: 0
  field :current_sign_in_at,      type: Time
  field :last_sign_in_at,         type: Time
  field :current_sign_in_ip,      type: String
  field :last_sign_in_ip,         type: String

  # Confirmable
  field :confirmation_token,      type: String
  field :confirmed_at,            type: Time
  field :confirmation_sent_at,    type: Time
  field :unconfirmed_email,       type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts,         type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,            type: String # Only if unlock strategy is :email or :both
  field :locked_at,               type: Time

  ## Yodlee
  field :yodlee_username, type: String, default: ""
  field :yodlee_password, type: String, default: ""

  after_create :set_yodlee_credentials
  after_create :add_to_yodlee
  before_destroy :remove_from_yodlee


  def full_name
    self.first_name + " " + self.last_name
   end

  def yodlee
    @yodlee ||= Yodlee::User.new(self)
  end

  def set_yodlee_credentials
    if Yodlee::Settings::YodleeAuth.register_users
      self.yodlee_username = "user#{id}@your-app-name.com"
      self.yodlee_password = Yodlee::Misc.password_generator
      save!
    else
      if Rails.env == 'development'
        self.yodlee_username = "sbMemsaverd_dev2"
        self.yodlee_password = "sbMemsaverd_dev2#123"
      else
        self.yodlee_username = "sbMemsaverd_dev1"
        self.yodlee_password = "sbMemsaverd_dev1#123"
      end
      save!
    end
  end

  def add_to_yodlee
    yodlee.register if Yodlee::Settings::YodleeAuth.register_users
  end

  def remove_from_yodlee
    yodlee.destroy if Yodlee::Settings::YodleeAuth.register_users
  end

  def transaction_available_from_date
    Transaction.where(:user_id => self.id).sort(:post_date => 1).first.post_date
  end

  def to_api_map
    {
        'id'              => id,
        'first_name'      => first_name,
        'last_name'       => last_name,
        'email'           => email,
        'phone'           => phone
    }
  end


end
