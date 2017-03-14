class Admin::AdminApplicationController < ApplicationController
  before_filter :authenticate_admin
  layout 'admin_application_layout'

  protected
  def authenticate_admin
    authenticate_or_request_with_http_basic do |username, password|
      username == "saverd" && password == "yodlee@saverd1234"
    end
  end
end