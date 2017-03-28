class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :yi,  as: :yodlee_id,               type: Integer
  field :sc,  as: :status_code,             type: Integer, :default => 801
  field :lr,  as: :last_refresh,            type: Time
  field :ia,  as: :item_account_id,         type: Array, default: []
  field :ab,  as: :available_balance,       type: Hash, :default => {}
  field :at,  as: :acc_type,                type: Hash, :default => {}

  belongs_to :user
  belongs_to :bank

  # Methods
  def yodlee
    @yodlee ||= Yodlee::Account.new(self)
  end

  # Methods
  def mfa
    @mfa ||= Yodlee::Mfa.new(self)
  end


  Error = {
      0 => 'Success',
      801 => 'REFRESH_NEVER_DONE',
      802 => "REFRESH_NEVER_DONE_AFTER_CREDENTIALS_UPDATE",
      409 => "STATUS_SITE_UNAVAILABLE",
      411 => "STATUS_SITE_OUT_OF_BUSINESS",
      412 => "STATUS_SITE_APPLICATION_ERROR",
      415 => "STATUS_SITE_TERMINATED_SESSION",
      416 => "STATUS_SITE_SESSION_ALREADY_ESTABLISHED",
      418 => "STATUS_HTTP_DNS_ERROR_EXCEPTION",
      423 => "STATUS_ACCT_INFO_UNAVAILABLE",
      424 => "STATUS_SITE_DOWN_FOR_ MAINTENANCE",
      425 => "STATUS_CERTIFICATE_ERROR",
      426 => "STATUS_SITE_BLOCKING",
      505 => "STATUS_SITE_CURRENTLY_NOT_SUPPORTED",
      510 => "STATUS_PROPERTY_RECORD_NOT_FOUND",
      511 => "STATUS_HOME_VALUE_NOT_FOUND",
      402 => "STATUS_LOGIN_FAILED",
      405 => "STATUS_USER_ABORTED_REQUEST",
      406 => "STATUS_PASSWORD_EXPIRED",
      407 => "STATUS_ACCOUNT_LOCKED",
      414 => "STATUS_NO_ACCT_FOUND",
      417 => "STATUS_DATA_MODEL_NO_SUPPORT",
      420 => "STATUS_SITE_MERGED_ERROR",
      421 => "STATUS_UNSUPPORTED_LANGUAGE_ERROR",
      422 => "STATUS_ACCOUNT_CANCELED",
      427 => "STATUS_SPLASH_PAGE_EXCEPTION",
      428 => "STATUS_TERMS_AND_CONDITIONS_EXCEPTION",
      429 => "STATUS_UPDATE_INFORMATION_EXCEPTION",
      430 => "STATUS_SITE_NOT_SUPPORTED",
      433 => "STATUS_REGISTRATION_PARTIAL_SUCCESS",
      434 => "STATUS_REGISTRATION_FAILED_ERROR",
      435 => "STATUS_REGISTRATION_INVALID_DATA",
      436 => "REGISTRATION_ACCOUNT_ALREADY_REGISTERED",
      506 => "NEW_LOGIN_INFO_REQUIRED_FOR_SITE",
      512 => "NO_PAYEES_ARE_FOUND_ON_SOURCE",
      518 => "NEW_MFA_INFO_REQUIRED_FOR_AGENTS",
      519 => "MFA_INFO_NOT_PROVIDED_TO_YODLEE_BY_USER_FOR_AGENTS",
      520 => "MFA_INFO_MISMATCH_FOR_AGENTS",
      521 => "ENROLL_IN_MFA_AT_SITE",
      522 => "MFA_INFO_NOT_PROVIDED_IN_REAL_TIME_BY_USER_VIA_APP",
      523 => "INVALID_MFA_INFO_IN_REAL_TIME_BY_USER_VIA_APP",
      524 => "USER_PROVIDED_REAL_TIME_MFA_DATA_EXPIRED",
      526 => "INVALID_MFA_INFO_OR_CREDENTIALS",
      401 => "NO_CONNECTION",
      403 => "INTERNAL_ERROR",
      404 => "LOST_REQUEST",
      408 => "DATA_EXPECTED",
      413 => "REQUIRED_FIELD_UNAVAILABLE",
      419 => "LOGIN_NOT_COMPLETED",
      507 => "BETA_SITE_WORK_IN_PROGRESS",
      508 => "INSTANT_REQUEST_TIMEDOUT",
      509 => "TOKEN_ID_INVALID",
      517 => "GENERAL_EXCEPTION_WHILE_GATHERING_MFA_DATA",
      525 => "MFA_INFO_NOT_PROVIDED_IN_REAL_TIME_BY_GATHERER",
      709 => "STATUS_FIELD_NOT_AVAILABLE",
  }


end
