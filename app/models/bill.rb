class Bill < ApplicationRecord

  def self.getAccountDetails
    require "json"

    domain = Rails.application.secrets.ZUORA_API_DOMAIN
    endpoint = domain + '/v1/accounts/A00000029'
    puts endpoint
    usrname = Rails.application.secrets.ZUORA_USERNAME
    pass = Rails.application.secrets.ZUORA_PASSWORD

    auth1 = usrname + ':' + pass
    auth1_enc = "Basic " + Base64.encode64(auth1).strip


    auth_header = {"Content-Type" => "application/json", "Cache-Control" => "no-cache", "Authorization" => auth1_enc}
    puts auth_header

    begin
      #TODO try to force api call failure and handle it here
      response = HTTParty.get( endpoint, :headers => auth_header)

    rescue Exception=> e
      puts e
      puts response
    end

    begin
      parsed = JSON.parse(response.body)
    rescue JSON::ParserError
      result=1
      parsed = {success: "false", error: {message: "Could not retrieve JSON response", code: "CUSTOM"}}
    end

    #result = JSON.unparse(response)
    puts response.body
    #Rails.logger.info(JSON.unparse(response))
    #
    return parsed

  end

  class Source
    attr_reader :type, :number, :expiry_month, :expiry_year, :name, :cvv
    attr_writer :type, :number, :expiry_month, :expiry_year, :name, :cvv

    def getJSON
      payload={}
      payload[:type] = type
      payload[:number] = number
      payload[:expiry_month] = expiry_month
      payload[:expiry_year] = expiry_year
      payload[:name] = name
      payload[:cvv] = cvv

      return payload
    end
  end

  class CKO_Pay
    attr_reader :source, :amount, :currency, :reference
    attr_writer :source, :amount, :currency, :reference

    def getJSON
      payload={}
      payload["source"]= source
      payload[:amount] = amount
      payload[:currency] = currency
      payload[:reference] = reference

      return payload
    end
  end

  def self.createPayment(param)
    puts param["cvv"]
    source = Source.new
    source.type = param["type"]
    source.number = param["number"]
    source.expiry_month = param["expiry_month"]
    source.expiry_year = param["expiry_year"]
    source.name = param["name"]
    source.cvv = param["cvv"]

    ckop = CKO_Pay.new
    ckop.source = source.getJSON
    ckop.amount = param["amount"]
    ckop.currency = param["currency"]
    ckop.reference = param["reference"]

    post_body = JSON.unparse(ckop.getJSON)

    domain = Rails.application.secrets.CKO_API_DOMAIN
    endpoint = domain + '/payments'
    auth = Rails.application.secrets.CKO_WEB_SK
    auth_header = {"Content-Type" => "application/json", "Cache-Control" => "no-cache", "Authorization" => auth}

    puts post_body

    begin
      #TODO try to force api call failure and handle it here
      response = HTTParty.post(endpoint, :headers => auth_header, :body => post_body)
    rescue Exception=> e
      puts e
    end

    #puts response.body
    response = JSON.parse(response.body)
    puts response
    puts 'RES::'
    if response["approved"] == true
      result ={}
      result["approved"] = true
      result["response_summary"] = response["response_summary"]
      puts result
      return result
    else
      result ={}
      result["approved"] = false
      result["response_summary"] = response["response_summary"]
      result["error_type"] = response["error_type"]
      result["error_codes"] = response["error_codes"]
      puts result
      return result
    end
  end

  def self.createCreditMemo(amount)
    payload='{
    "accountId": "2c92c0fa6c8aee2e016c8cb747e90a4d",
    "autoPost": true,
    "charges": [
        {
            "chargeId": "2c92c0f86a2f3322016a30d5e11b2682",
            "memoItemAmount": AMOUNT
        }
    ],
    "comment": "Check",
    "effectiveDate": "2020-07-21",
    "reasonCode": "Ad hoc credit"
}'
    post_body = payload.sub("AMOUNT",amount)

    domain = Rails.application.secrets.ZUORA_API_DOMAIN
    endpoint = domain + '/v1/creditmemos'
    puts endpoint
    usrname = Rails.application.secrets.ZUORA_USERNAME
    pass = Rails.application.secrets.ZUORA_PASSWORD

    auth1 = usrname + ':' + pass
    auth1_enc = "Basic " + Base64.encode64(auth1).strip

    auth_header = {"Content-Type" => "application/json", "Cache-Control" => "no-cache", "Authorization" => auth1_enc}
    puts auth_header

    begin
      #TODO try to force api call failure and handle it here
      response = HTTParty.post( endpoint, :headers => auth_header, :body => post_body)

    rescue Exception=> e
      puts e
      puts response
    end

    puts response.body
    response = JSON.parse(response.body)
    puts response
    if response["status"] == "Posted"
      return true
    else
      return false
    end

  end

end
