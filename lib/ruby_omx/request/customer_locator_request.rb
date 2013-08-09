module RubyOmx

  class CustomerLocatorRequest < Request

    def initialize(attrs={})
      return super unless attrs.any?
      @attrs = attrs
      raise RubyOmx::MissingSearchCriteria.new(RubyOmx::CustomerLocatorRequest.allowed_search_parameters.keys) if search_criteria.empty?
      create_attr_accessors_for_allowed_search_parameters
      super
      self.version = attrs[:version] ||= '1.00'
      create_udi_parameters_from_search_criteria
    end
    xml_name "CustomerLocatorRequest"
        
    def search_criteria
      @search_criteria ||= @attrs.select{ |key,value| RubyOmx::CustomerLocatorRequest.allowed_search_parameters.keys.include?(key) }
    end

    def self.allowed_search_parameters
      # ruby_variable => xml_name
      { :customer_number => "CustomerNumber",
        :order_number => "OrderNumber",
        :first_name => "FirstName",
        :last_name => "LastName",
        :company => "Company",
        :zip => "ZIP",
        :house_number => "HouseNumber",
        :email => "Email",
        :phone_number => "PhoneNumber",
        :credit_card_number => "CreditCardNumber" }
    end

    def create_udi_parameters_from_search_criteria
      search_criteria.each_pair do |search_key, search_value|
        self.udi_parameters << UDIParameter.new({:key=>RubyOmx::CustomerLocatorRequest.allowed_search_parameters[search_key], :value=>search_value})        
      end
    end

    def create_attr_accessors_for_allowed_search_parameters
      RubyOmx::CustomerLocatorRequest.allowed_search_parameters.keys.each { |search_key| self.class.send(:attr_accessor, search_key) }
    end

  end
end