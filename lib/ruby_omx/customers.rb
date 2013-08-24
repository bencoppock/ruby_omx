module RubyOmx
  module Customers

    # CustomerLocatorRequest (CLR100) This request type lists possible matches for a customer given some search information.

    def build_customer_locator_request(attrs={})
      CustomerLocatorRequest.new(attrs.merge({:udi_auth_token=>@udi_auth_token, :http_biz_id=>@http_biz_id}))
    end

    def send_customer_locator_request(attrs={})
      request = build_customer_locator_request(attrs)
      response = post(request.to_xml.to_s)
      return response if request.raw_xml==true || request.raw_xml==1
      CustomerLocatorResponse.format(response)
    end
    alias_method :search_customers, :send_customer_locator_request

    # CustomerInformationRequest (CIR100) This request type provides the customer address and customer flags for a given customer number.

    def build_customer_information_request(attrs={})
      CustomerInformationRequest.new(attrs.merge({:udi_auth_token=>@udi_auth_token, :http_biz_id=>@http_biz_id}))
    end

    def send_customer_information_request(attrs={})
      request = build_customer_information_request(attrs)
      response = post(request.to_xml.to_s)
      return response if request.raw_xml==true || request.raw_xml==1
      CustomerInformationResponse.format(response)
    end
    alias_method :get_customer_info, :send_customer_information_request

    # CustomerHistoryRequest (CUHR200) This request type lists all the orders that a customer has placed.

    def build_customer_history_request(attrs={})
      CustomerHistoryRequest.new(attrs.merge({:udi_auth_token=>@udi_auth_token, :http_biz_id=>@http_biz_id}))
    end

    def send_customer_history_request(attrs={})
      @connection = RubyOmx::Connection.connect({ 'udi_auth_token' => @udi_auth_token, 'http_biz_id' => @http_biz_id, 'server' => ALT_HOST })
      request = build_customer_history_request(attrs)
      response = post(request.to_xml.to_s)
      return response if request.raw_xml==true || request.raw_xml==1
      CustomerHistoryResponse.format(response)
    end
    alias_method :purchase_history, :send_customer_history_request

  end
end