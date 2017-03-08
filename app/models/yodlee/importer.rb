require 'base64'
module Yodlee
  class Importer < Base

    def content_services *type
      # types allowed: :all, OR specific type(s), :bank, :credits, :miles, :loans etc
      all_content_services.each do |bank|
        container = bank.containerInfo.containerName.to_sym
        next unless Array(type).include?(container) || type == :all

        mfa = bank.key?('mfaType') ? bank.mfaType.typeName : 'none'

        row = ::Bank.where(content_service_id: bank.contentServiceId).first_or_create
        row.update_attributes!(
            :content_service_id           => bank.contentServiceId,
            :home_url                     => bank.homeUrl,
            :content_service_display_name => bank.contentServiceDisplayName,
            :site_id                      => bank.siteId,
            :site_display_name            => bank.siteDisplayName,
            :container                    => container,
            :mfa                          => mfa,
            :image                        => get_site_logo(bank.siteId)
        )
      end
    end


    private

    def all_content_services
      query({
                :endpoint => '/jsonsdk/ContentServiceTraversal/getAllContentServices',
                :method => :POST,
                :params => {
                    :cobSessionToken => cobrand_token,
                    :notrim => true
                }
            })
    end

    def get_site_logo (site_id)
      response = query({
                           :endpoint => '/jsonsdk/SiteTraversal/getSiteInfo',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               'siteFilter.siteId' => site_id,
                               'siteFilter.reqSpecifier' => 128
                           }
                       })
      if response.defaultSiteLogo.nil? || response.defaultSiteLogo.bytes.nil?
        ''
      else
        Base64.strict_encode64(response.defaultSiteLogo.bytes.pack('C*'))
      end
    end





  end
end