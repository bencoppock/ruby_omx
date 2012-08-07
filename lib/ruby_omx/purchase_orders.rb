module RubyOmx
  module PurchaseOrders
    
    # Universal Direct Order Appending (UDOA)
    
    def build_purchase_order_update_request(params={})
		  PurchaseOrderUpdateRequest.new(params.merge({:udi_auth_token=>@udi_auth_token, :http_biz_id=>@http_biz_id}))
		end
		
		def send_purchase_order_update_request(params={})
		  request = build_purchase_order_update_request(params)
      response = post(request.to_xml.to_s)
      return response if request.raw_xml==true || request.raw_xml==1
      PurchaseOrderUpdateResponse.format(response)		  
		end
		alias_method :append_po, :send_purchase_order_update_request
		
  end
end
