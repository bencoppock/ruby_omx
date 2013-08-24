module RubyOmx

  class CustomerHistoryRequest < Request

    def initialize(attrs={})
      return super unless attrs.any?
      raise MissingRequestOptions if attrs[:customer_number].nil?
      super
      self.version = attrs[:version] ||= '2.00'
      self.udi_parameters << UDIParameter.new({:key=>'CustomerNumber', :value=>attrs[:customer_number]})
      self.udi_parameters << UDIParameter.new({:key=>'Level', :value=>attrs[:level]}) if attrs[:level]
      self.udi_parameters << UDIParameter.new({:key=>'MaxOrders', :value=>attrs[:max_orders]}) if attrs[:max_orders]
      self.udi_parameters << UDIParameter.new({:key=>'FromOrderNumber', :value=>attrs[:from_order_number]}) if attrs[:from_order_number]
    end

    attr_accessor :customer_number, :level, :max_orders, :from_order_number
    xml_name "CustomerHistoryRequest"
  end
end
