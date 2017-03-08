require 'settings'
ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                       :access_key_id     => Yodlee::Settings::WebApp.access_key,
                                       :secret_access_key => Yodlee::Settings::WebApp.secret,
                                       :server=> Yodlee::Settings::WebApp.ses_host
AWS::SES::SendEmail.class_eval do
  # TN: made bbc work with ses
  def send_raw_email(mail, args = {})
    message = mail.is_a?(Hash) ? Mail.new(mail).to_s : mail.to_s
    package = { 'RawMessage.Data' => Base64.encode64(message) }
    package['Source'] = args[:from] if args[:from]
    package['Source'] = args[:source] if args[:source]

    # Extract the list of recipients based on arguments or mail headers
    destinations = []
    if args[:destinations]
      destinations.concat args[:destinations].to_a
    elsif args[:to]
      destinations.concat args[:to].to_a
    else
      destinations.concat mail.to.to_a
      destinations.concat mail.cc.to_a
      destinations.concat mail.bcc.to_a
    end
    add_array_to_hash!(package, 'Destinations', destinations) if destinations.length > 0

    request('SendRawEmail', package)
  end

  alias :deliver! :send_raw_email
  alias :deliver  :send_raw_email

end