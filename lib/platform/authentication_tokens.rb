class AuthenticationTokens
  include Singleton

  #DEVISE_AUTH_TOKEN_SECRET from devise.rb

  #TODO implement a logic for encrypting and decrypting auth_token
  def self.generate(user_id)
    token_for(user_id.to_s,10.years.from_now,0.1)
  end

  def self.token_val(token)
    begin
      token_parts = base64_url_decode(token).split('|')
      message = token_parts[0..-2].join('|') + '|'
      digest_in = token_parts[-1]
      digest_new = digest(message)
      identity = token_parts[0]
      expires_at = token_parts[1].to_i
      # First version of token did not have API version in it, so needs to be handled specially
      api_version = token_parts.length < 4 ? 0.1 : token_parts[2].to_f
      if digest_in != digest_new
        Rails.logger.error "detected tampering"
        return nil
      end
      return identity
    rescue Exception=>e
      Rails.logger.error "Error decoding access token"
      Rails.logger.error e.to_s
    end
    return nil
  end


  private

  def self.token_for(identity, expires_at, current_api_version)
    message = identity + '|' + expires_at.to_s + '|' + (version_as_string current_api_version) + '|'
    base64_url_encode(message + digest(message))
  end

  def self.digest(message)
    base64_url_encode(Digest::SHA256.new.digest(message + DEVISE_AUTH_TOKEN_SECRET))
  end

  def self.base64_url_encode(str)
    Base64.encode64(str).tr('+/', '-_').gsub(/=*$/, '').gsub(/\n/, '')
  end

  def self.base64_url_decode(str)
    str += '=' * (4 - str.length.modulo(4))
    Base64.decode64(str.tr('-_', '+/'))
  end

  def self.version_as_string(api_version)
    "%.1f" % api_version
  end

end