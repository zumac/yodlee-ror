class Bank
  include Mongoid::Document

  field :csi,   as: :content_service_id,            type: Integer
  field :csdn,  as: :content_service_display_name,  type: String
  field :si,    as: :site_id,                       type: Integer
  field :sdn,   as: :site_display_name,             type: String
  field :mfa,   as: :mfa,                           type: String
  field :hu,    as: :home_url,                      type: String
  field :co,    as: :container,                     type: String
  field :img,   as: :image,                         type: String

  def yodlee
    @yodlee ||= Yodlee::Bank.new(self)
  end

  def self.find_by_content_service_id(id)
    self.where(:content_service_id => id).first
  end

  MFAUserResponse = {
      'TOKEN_ID' => :MFATokenResponse,
      'IMAGE' => :MFAImageResponse,
      'SECURITY_QUESTION' => :MFAQuesAnsResponse
  }

end
