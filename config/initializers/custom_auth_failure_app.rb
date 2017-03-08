class CustomAuthFailure < Devise::FailureApp
  def respond
    if request.format == Mime::JSON
      self.status = 401
      self.content_type = 'json'
      self.response_body = {status: :false, error:{code: 000, message:i18n_message }}.to_json
      if warden_message.eql? :unconfirmed
        self.response_body = {status: :false, error:{code: 705, message:i18n_message }}.to_json
      end
    else
      super
    end
  end
end