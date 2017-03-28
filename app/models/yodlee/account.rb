module Yodlee
  class Account < Base

    attr_reader :account

    def initialize account
      @account = account
    end

    def bank
      account.bank
    end

    def user
      @user ||= account.user
    end

    def item_id
      account.yodlee_id
    end

    def token
      user.yodlee.token
    end

    def parse_creds creds
      all_fields = bank.yodlee.login_requirements.componentList
      creds.each_with_index.inject({}) do |sum, (cred, index)|
        key, value = cred
        field = all_fields.find { |f| f.valueIdentifier == key }

        sum[:"credentialFields[#{index}].fieldType.typeName"] = field.fieldType.typeName
        sum[:"credentialFields[#{index}].value"] = value

        %w( displayName helpText maxlength name size valueIdentifier valueMask isEditable isOptional isEscaped isMFA isOptionalMFA ).each do |attr|
          sum[:"credentialFields[#{index}].#{attr}"] = field.send(attr)
        end

        sum
      end
    end

    def create creds
      response = query({
                           :endpoint => '/jsonsdk/ItemManagement/addItemForContentService1',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               :userSessionToken => token,
                               :contentServiceId => bank.content_service_id,
                               :shareCredentialsWithinSite => true,
                               :startRefreshItemOnAddition => false,
                               :'credentialFields.enclosedType' => 'com.yodlee.common.FieldInfoSingle'
                           }.merge(parse_creds(creds))
                       })

      if response
        account.update_attributes!(yodlee_id: response.primitiveObj)
        refresh
        return true
      else
        return false
      end
    end

    def remove
      response = query({
                           :endpoint => '/jsonsdk/ItemManagement/removeItem',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               :userSessionToken => token,
                               :itemId => item_id.to_s,
                           }
                       })
    end

    def refresh
      query({
                :endpoint => '/jsonsdk/Refresh/startRefresh7',
                :method => :POST,
                :params => {
                    :cobSessionToken => cobrand_token,
                    :userSessionToken => token,
                    :itemId => item_id,
                    :'refreshParameters.refreshMode.refreshMode' => 'NORMAL',
                    :'refreshParameters.refreshMode.refreshModeId' => 2,
                    :'refreshParameters.refreshPriority' => 1
                }
            })
    end

    def is_refreshing?
      response = query({
                           :endpoint => '/jsonsdk/Refresh/isItemRefreshing',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               :userSessionToken => token,
                               :memItemId => item_id
                           }
                       })

      response.primitiveObj
    end

    def ping
      sleep(2)
      if is_refreshing?
        ping
      else
        get_last_refresh_info
        if account.status_code == 0
          get_item_summary
        end
      end
    end

    def get_last_refresh_info
      response = query({
                           :endpoint => '/jsonsdk/Refresh/getRefreshInfo1',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               :userSessionToken => token,
                               :'itemIds[0]' => item_id
                           }
                       })

      if response && response = response.find { |a| a.itemId == item_id }
        account.status_code = response.statusCode
        account.last_refresh = Time.at(response.lastUpdateAttemptTime)
        account.save
      end
    end

    def get_item_summary
      response = query({
                           :endpoint => '/jsonsdk/DataService/getItemSummaryForItem1',
                           :method => :POST,
                           :params => {
                               :cobSessionToken => cobrand_token,
                               :userSessionToken => token,
                               :itemId => item_id,
                               :'dex.startLevel' => 0,
                               :'dex.endLevel' => 0,
                               :'dex.extentLevels[0]' => 4,
                               :'dex.extentLevels[1]' => 4
                           }
                       })

      if response
        account.status_code = response['refreshInfo']['statusCode']
        account.item_account_id = response['itemData']['accounts'].map{|m| m.itemAccountId}
        response['itemData']['accounts'].each do | inner_account |
          if inner_account.availableBalance.present?
            account.available_balance.merge!({ inner_account.itemAccountId => inner_account.availableBalance.amount})
          else
            account.available_balance.merge!({ inner_account.itemAccountId => -1 * inner_account.runningBalance.amount })
          end
          account.acc_type.merge!({ inner_account.itemAccountId => inner_account.acctType })
        end
        account.save
      end
    end

    def last_available_transaction(account_id)
      last_transaction = Transaction.where(item_id: account_id).sort({post_date: 1}).last
      last_transaction.nil? ? 5.years.ago.strftime('%m-%d-%Y') : last_transaction.post_date.strftime('%m-%d-%Y')
    end

    def get_transaction_data
      account.item_account_id.each do |account_id|
        return_data = query({
                                :endpoint => '/jsonsdk/TransactionSearchService/executeUserSearchRequest',
                                :method => :POST,
                                :params => {
                                    :cobSessionToken => cobrand_token,
                                    :userSessionToken => token,
                                    :'transactionSearchRequest.containerType' => 'All',
                                    :'transactionSearchRequest.higherFetchLimit' => 500,
                                    :'transactionSearchRequest.lowerFetchLimit' => 1,
                                    :'transactionSearchRequest.resultRange.endNumber' => 500,
                                    :'transactionSearchRequest.resultRange.startNumber' => 1,
                                    :'transactionSearchRequest.searchClients.clientId' => 1,
                                    :'transactionSearchRequest.searchClients.clientName' => 'DataSearchService',
                                    :'transactionSearchRequest.ignoreUserInput' => true,
                                    :'transactionSearchRequest.searchFilter.postDateRange.fromDate' => last_available_transaction(account_id),
                                    # :'transactionSearchRequest.searchFilter.postDateRange.toDate' => Time.now.strftime('%m-%d-%Y'),
                                    :'transactionSearchRequest.searchFilter.itemAccountId.identifier' => account_id,
                                    :'transactionSearchRequest.searchFilter.transactionSplitType' => 'ALL_TRANSACTION'
                                }
                            })
        Rails.logger.info "FETCHED #{return_data.count} NEW TRANSACTION ENTRIES"
        save_fetched_transaction(return_data)
      end
    end

    def save_fetched_transaction(transactions)
      if transactions["searchResult"].present?
        transactions["searchResult"]["transactions"].each do | transaction_obj |
          transaction = Transaction.where(id: transaction_obj['viewKey']['transactionId']).first_or_create
          transaction.update_attributes!(
              account_name: transaction_obj['account']['accountName'],
              account_number: transaction_obj['account']['accountNumber'],
              amount: transaction_obj['amount']['amount'],
              balance: transaction_obj['account']['accountBalance']['amount'],
              currency_code: transaction_obj['amount']['currencyCode'],
              transaction_type: transaction_obj['transactionType'],
              category_name: transaction_obj['category']['categoryName'],
              original_category_name: transaction_obj['category']['categoryName'],
              description: transaction_obj['description']['description'],
              post_date: transaction_obj['postDate'],
              item_id: transaction_obj['account']['itemAccountId'],
              dump: transaction_obj,
              user_id: user.id
          )
        end
      end

    end

  end
end