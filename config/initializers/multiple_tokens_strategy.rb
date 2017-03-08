require 'platform/authentication_tokens'
module Devise
  module Strategies
    class MultipleTokensStrategy < Devise::Strategies::Base
      def store?
        false
      end

      def valid?
        request.headers['HTTP_X_AUTH_TOKEN'] || params[:auth_token_custom]
      end

      def authenticate!
        user_id_str = AuthenticationTokens.token_val(request.headers['HTTP_X_AUTH_TOKEN'] || params[:auth_token_custom])

        if user_id_str
          user = User.find(user_id_str)
          if user
            user.after_database_authentication
            success!(user)
            return
          end
        end

        return fail(:not_found_in_database)
        #if (!(params[:user]) && !halted?)
        #  fail!("Invalid authentication token.")
        #
        #
        #end
      end
    end
  end
end
