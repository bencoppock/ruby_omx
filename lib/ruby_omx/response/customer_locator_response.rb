# CustomerLocatorRequest (CLR100) This request type lists possible matches for a customer given some search information.

module RubyOmx

  class Stats < Node
    xml_name 'Stats'
    xml_reader :last_order_date
    xml_reader :last_contact_date
  end

  class Customer < Node
    xml_name 'Customer'
    xml_reader :customer_number, :from => '@customerNumber'
    xml_reader :level_code, :from => '@code', :in => 'Level'
    xml_reader :level
    xml_reader :address, :as => Address
    xml_reader :flags, :as => [Flag], :in => 'FlagData'
    xml_reader :stats, :as => Stats    
  end
  
  class CustomerLocatorResponse < StandardResponse
    xml_name 'CustomerLocatorResponse'
    xml_reader :customers, :as => [Customer]
  end
    
end
