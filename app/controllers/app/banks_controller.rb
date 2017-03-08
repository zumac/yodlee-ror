class App::BanksController < ApplicationController

  before_action :authenticate_user!, :only => [:login]

  def index
    if params[:query].present?
      if Rails.env == 'development'
        banks = Bank.and({:content_service_display_name => /^#{params[:query]}/i}).limit(12)
      else
        banks = Bank.and({:content_service_display_name => /^#{params[:query]}/i},{ :content_service_display_name => /\(UK\)/i}).limit(12)
      end
    else
      banks = Bank.where(:img.ne => '', :content_service_display_name => /\(UK\)/i).limit(12)
    end
    render json: {
               status: :true,
               banks: banks
           }
  end

  def login_requirement
    bank = Bank.where(:content_service_id => params[:id].to_i).first
    if params[:fields].present?
      render json: {
                 status: :true,
                 fields: bank.yodlee.login_requirements
             }
    else
      login_requirement = bank.yodlee.form
      render json: {
                 status: :true,
                 form: login_requirement
             }
    end

  end

  def login_mfa
    user = current_user
    user.yodlee.login
    account = Account.where(:yodlee_id => params['bank']['item_id']).first
    mfa_type = Bank::MFAUserResponse[account.bank.mfa]
    params['bank'].delete('item_id')
    response = account.mfa.put_mfa_request(mfa_type, params['mfa_response']['fieldInfo'], params['bank'])
    render json: {
               status: :true,
               result: {
                   response: response
               }
           }

  end

  def login
    user = current_user
    user.yodlee.login
    bank = Bank.find_by_content_service_id(params[:bank][:id].to_i)
    account = Account.create!(user: user, bank: bank)
    params[:bank].delete('id')
    if account.yodlee.create(params[:bank])
      if bank.mfa != 'none'
        response = account.mfa.get_mfa_response_form
        form = Yodlee::Form.new({ mfa_fields: response['fieldInfo'] }).render_mfa_form
        render json: {
                 status: :true,
                 result: {
                     mfa: :true,
                     html: form,
                     item_id: account.yodlee_id,
                     response: response
                 }

               }
      else
        account.yodlee.ping
        Rails.cache.delete "#{current_user.id}-transactions"
        Rails.cache.delete "#{current_user.id}-balance"
        render json: {
                   status: :true,
                   result: {
                       mfa: :false
                   }
               }
      end
    end
  end

end
