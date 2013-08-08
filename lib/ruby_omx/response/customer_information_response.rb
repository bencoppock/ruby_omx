# CustomerInformationRequest (CIR100) This request type provides the customer address and customer flags for a given customer number.

module RubyOmx

  class CustomerInformationResponse < StandardResponse
    xml_name "CustomerInformationResponse"

    xml_reader :customer_number, :from => '@customerNumber', :in => 'Customer'
    xml_reader :bill_to, :as => Address, :in => 'Customer'
    xml_reader :flags, :as => [Flag], :in => 'Customer/FlagData'
    xml_reader :custom_fields, :as => [CustomField], :in => 'Customer/CustomFields'
    
    def to_s
      "#{super}, Customer # #{customer_number}, Name: #{bill_to.first_name} #{bill_to.last_name}, Flag count: #{flags.length}, Custom Field count: #{custom_fields.length}"
    end
  end
end
