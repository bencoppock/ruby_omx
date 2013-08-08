module RubyOmx
  module Customers
    
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
  end
end