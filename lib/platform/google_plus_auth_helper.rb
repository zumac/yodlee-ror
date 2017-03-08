require 'net/http'

module Yodlee::Platform
  module GoogleAuthHelper
    class << self

      def gp_authenticate access_token
        gp_user = get_google_user(access_token)
        return create_or_get_user(gp_user)
      end


      def create_or_get_user(gp_user)
        resource = User.find_for_database_authentication(gp_id: gp_user['id'])
        if resource
          return {user: resource, new: false}
        else
          resource = User.find_for_database_authentication(email: gp_user['email'])
          if resource
            resource.gp_id = gp_user['id']
            resource.save!
            return {user: resource, new: false}
          else
            resource = User.new({
                                    :first_name => gp_user['given_name'],
                                    :last_name => gp_user['family_name'],
                                    :email => gp_user['email'],
                                    :display_name => gp_user['name'],
                                    :gender =>  gp_user['gender'] == "male"? "Male":"Female",
                                    :gp_id => gp_user['id'],
                                    :password => Devise.friendly_token[0,20]
                                })

            resource.save!
            return {user: resource, new: true}
          end
        end
      end

      def get_google_user(access_token)
        uri = URI('https://www.googleapis.com/oauth2/v2/userinfo')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        authorization = "OAuth #{access_token}"
        request.add_field('Access_token', access_token)
        request.add_field('Authorization', authorization)
        user_info = JSON.load(http.request(request).body)
        user_info
      end

    end
  end
end