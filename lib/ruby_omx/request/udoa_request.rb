module RubyOmx

  class UDOARequest < Request
    def initialize(attrs={})
      return super unless attrs.any?

  		required_fields = [:queue_flag, :verify_flag, :keycode, :order_date, :order_id, :bill_to, :line_items, :method_code]
  		raise MissingRequestOptions if required_fields.any? { |option| attrs[option].nil? }
      super
      self.version = attrs[:version] ||= '2.00'
      self.payment_type = attrs[:payment_type] ||= '6'  #6 for open invoice
      self.origin_type = attrs[:origin_type] ||= '2'    # 2 = phone order, 3 = internet order      
      self.udi_parameters << UDIParameter.new({:key=>'Keycode', :value=>attrs[:keycode]})
      self.udi_parameters << UDIParameter.new({:key=>'VerifyFlag', :value=>attrs[:verify_flag] ||= 'True' }) # Determines whether a successful order should be saved, or only verified/calculated. When set to "True", OrderMotion will behave as if the order was placed, but not return an Order Number in the response.
      self.udi_parameters << UDIParameter.new({:key=>'QueueFlag', :value=>attrs[:queue_flag] ||= 'False' })  # Determines whether any orders with errors will be stored in the OrderMotion "Outside Order Queue",  to be corrected by an OrderMotion user before resubmission. If set to "True", almost all orders will be   accepted by OrderMotion, but additional order information will only be returned in the response if the order   is successfully placed. Otherwise, any order with any error (eg invalid ZIP code) will be rejected.
      self.udi_parameters << UDIParameter.new({:key=>'Vendor', :value=>attrs[:vendor] }) if attrs[:vendor].present? 
      self.bill_to = Address.new(attrs[:bill_to])
      self.ship_to = Address.new(attrs[:ship_to])
      
      # Instantiate LineItem variables for each
      i = 0
      self.line_items = attrs[:line_items].collect { |h|
        i+=1
        h[:line_number] = h[:line_number] ||= i  # Provide line numbers if they are omitted
        LineItem.new(h)
      }
        
      self.custom_fields = attrs[:custom_fields].collect { |h| CustomField.new(h) } if attrs[:custom_fields].present?
      self.flags = attrs[:flags].collect { |h| Flag.new(h) } if attrs[:flags].present?
    end
      
    attr_accessor :keycode, :queue_flag, :verify_flag, :vendor
      
    xml_name "UDOARequest"
    xml_accessor :order_date, :in => 'Header', :as => DateTime  # Dates are almost the same as the W3C Schema "date" type, but with a space instead of the "T" separating the date from the time.
    xml_accessor :order_id, :in => 'Header', :from => 'OrderID'
    xml_accessor :origin_type, :in => 'Header'
    xml_accessor :store_code, :in => 'Header'
    xml_accessor :bill_to, :as => Address, :in => 'Customer'
    xml_accessor :flags, :as => [Flag], :in => 'Customer/FlagData'
    xml_accessor :ship_to, :as => Address, :in => 'ShippingInformation'

    xml_accessor :method_code, :in => 'ShippingInformation', :as => Integer
    xml_accessor :shipping_amount, :in => 'ShippingInformation', :as => Float
    xml_accessor :handling_amount, :in => 'ShippingInformation', :as => Float
    xml_accessor :special_instructions, :in => 'ShippingInformation'
    xml_accessor :gift_wrapping, :in => 'ShippingInformation'
    xml_accessor :gift_message, :in => 'ShippingInformation'            

    xml_accessor :payment_type, :in => 'Payment', :from => '@type'
  	xml_accessor :card_number, :in => 'Payment'
  	xml_accessor :card_verification, :in => 'Payment'
  	xml_accessor :card_exp_date_month, :in => 'Payment'
  	xml_accessor :card_exp_date_year, :in => 'Payment'
    xml_accessor :card_status, :in => 'Payment'
  	xml_accessor :card_auth_code, :in => 'Payment' 	    	
  	xml_accessor :card_transaction_id, :from => 'CardTransactionID', :in => 'Payment'

    xml_accessor :line_items, :as => [LineItem], :in => 'OrderDetail'
    xml_accessor :custom_fields, :as => [CustomField], :in => 'CustomFields/Report'
    xml_accessor :total_amount, :in => 'Check'  
  end
end
