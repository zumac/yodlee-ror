module Yodlee
  class Mfa < Account

    attr_reader :account

    def initialize account
      @account = account
    end


    def get_mfa_response
      response = query({
                           :endpoint => '/jsonsdk/Refresh/getMFAResponse',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               :userSessionToken => token,
                               :itemId => item_id
                           }
                       })

    end

    def should_retry_get_mfa_response? response, try, max_trys
      return response['errorCode'] != nil && response['fieldInfo'].present? && response['fieldInfo']['numOfMandatoryQuestions'] == -1 && try < max_trys
    end

    def get_mfa_response_form refresh_interval= 2, max_trys= 10
      response = get_mfa_response

      try = 1
      while should_retry_get_mfa_response? response, try, max_trys
        try += 1
        sleep(refresh_interval)
        response = get_mfa_response
      end

      response
    end

    def put_mfa_request mfa_type, field_info, answers
      params = {  }

      case mfa_type.to_sym
        when :MFATokenResponse
          params['userResponse.token'] = field_info['fieldValue']
        when :MFAImageResponse
          params['userResponse.imageString'] = field_info['fieldValue']
        when :MFAQuesAnsResponse
          questionsArray = field_info['questionAndAnswerValues']
          i = 0
          while i < questionsArray.length do
            params["userResponse.quesAnsDetailArray[#{i}].answer"] = answers[questionsArray[i]['metaData'].gsub(/\./,"").underscore]
            params["userResponse.quesAnsDetailArray[#{i}].answerFieldType"]=questionsArray[i]['responseFieldType']
            params["userResponse.quesAnsDetailArray[#{i}].metaData"] = questionsArray[i]['metaData']
            params["userResponse.quesAnsDetailArray[#{i}].question"] = questionsArray[i]['question']
            params["userResponse.quesAnsDetailArray[#{i}].questionFieldType"]=questionsArray[i]['questionFieldType']
            i += 1
          end
      end

      response = query({
                           :endpoint => '/jsonsdk/Refresh/putMFARequest',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               :userSessionToken => token,
                               :itemId => item_id,
                               "userResponse.objectInstanceType" => "com.yodlee.core.mfarefresh.#{mfa_type}"
                           }.merge!(params)
                       })

    end

  end
end