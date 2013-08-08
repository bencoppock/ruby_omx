module RubyOmx

  class CustomerInformationRequest < Request

    def initialize(attrs={})
      return super unless attrs.any?
      raise MissingRequestOptions if attrs[:customer_number].nil?
      super
      self.version = attrs[:version] ||= '1.00'
      self.udi_parameters << UDIParameter.new({:key=>'CustomerNumber', :value=>attrs[:customer_number]})
    end

    attr_accessor :customer_number
    xml_name "CustomerInformationRequest"
  end
end
