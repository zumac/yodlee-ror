module Yodlee
  class Settings < Settingslogic

    namespace Rails.env

    class WebApp < Settingslogic
      source File.join(File.dirname(__FILE__), "..", "config","settings", "web_app.yml")
      namespace Rails.env
    end

    class SES < Settingslogic
      source File.join(File.dirname(__FILE__), "..", "config","settings", "ses.yml")
      namespace Rails.env
    end

    class YodleeAuth < Settingslogic
      source File.join(File.dirname(__FILE__), "..", "config","settings", "yodlee.yml")
      namespace Rails.env
    end

  end
end
