# CustomerHistoryRequest (CUHR200) This request type lists all the orders that a customer has placed.

module RubyOmx
  
  class Order < Node
    xml_name 'Order'
    xml_reader :order_number, :from=>'@orderNumber'    
    xml_reader :line_items, :as => [LineItem], :in => 'OrderDetail'
  end
  
  class CustomerHistoryResponse < StandardResponse
    xml_name 'CustomerHistoryResponse'
    xml_reader :orders, :as => [Order]
    xml_reader :customer_number, :in => 'BasicInformation'
    
    def to_s
      "#{super}, Customer # #{customer_number}, Order count: #{orders.length}"
    end
  end
end
