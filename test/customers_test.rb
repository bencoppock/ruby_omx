require 'test_helper'

class CustomersTest < MiniTest::Unit::TestCase
  def setup
    @config = YAML.load_file( File.join(File.dirname(__FILE__), 'test_config.yml') )['test']
    @connection = RubyOmx::Base.new(@config)
  end
  
  def test_customer_locator_search_criteria
    valid_search_criteria = { :customer_number => "10001",
                              :order_number => "24603",
                              :first_name => "Patrick",
                              :last_name => "Puck",
                              :company => "Order Motion",
                              :zip => "10001",
                              :house_number => "",
                              :email => "pmp@ordermotion.com",
                              :phone_number => "+1 (212) 8773920 x 123",
                              :credit_card_number => "4111111111111111" }
    
    valid_search_criteria.each_pair do |search_key, search_value|
      request = RubyOmx::CustomerLocatorRequest.new(search_key => search_value)
      assert_equal false, request.search_criteria.empty?
    end
    
    request = RubyOmx::CustomerLocatorRequest.new( :last_name => valid_search_criteria[:last_name], :zip => valid_search_criteria[:zip] )
    assert_equal 2, request.search_criteria.length
  end
  
  def test_customer_locator_request_from_xml
    request = RubyOmx::CustomerLocatorRequest.format(xml_for('CustomerLocatorRequest(1.00)',200))
    assert_equal '1.00', request.version
    assert_equal true, request.udi_parameters.collect{|udi_param| [udi_param.key, udi_param.value] }.include?(["ZIP", "294"])
    assert_equal true, request.udi_parameters.collect{|udi_param| [udi_param.key, udi_param.value] }.include?(["LastName", "ONeil"])
  end

  def test_customer_locator_request_to_xml
    request_attrs = { :last_name => 'ONeil', :zip => '294' }
    request = @connection.build_customer_locator_request(request_attrs)
    request2 = RubyOmx::CustomerLocatorRequest.format(xml_for('CustomerLocatorRequest(1.00)',200))
    assert_equal request.to_xml.to_s, request2.to_xml.to_s
  end
  
  def test_send_customer_locator_request
    @connection.stubs(:post).returns(xml_for('CustomerLocatorResponse(1.00)',200))
    response = @connection.search_customers({ :last_name => 'ONeil', :zip => '294' })
    
    assert_kind_of CustomerLocatorResponse, response
    assert_equal 1, response.customers.count
    
    customer = response.customers[0]
    assert_equal '10129', customer.customer_number
    assert_equal '4', customer.level_code
    assert_equal 'Gold', customer.level
    
    # Address
    address = customer.address
    assert_equal 'Ms', address.title_code
    assert_equal 'Ordermotion', address.company
    assert_equal 'Regina', address.first_name
    assert_equal 'Oneil', address.last_name
    assert_equal '9327 Marfield Rd', address.addr1
    assert_equal '', address.addr2
    assert_equal 'Summerville', address.city
    assert_equal 'SC', address.state
    assert_equal '29483-8643', address.zip
    assert_equal 'USA', address.country
    assert_equal 'US', address.tld
    assert_equal '', address.house_number
    assert_equal '', address.county
    assert_equal '9327 Marfield Rd', address.street1
    assert_equal '', address.street2
    assert_equal '', address.apartment
    assert_equal '', address.house_name
    assert_equal '', address.dependent_locality
    assert_equal '+1 (212) 8773920 x 123', address.phone_number
    assert_equal 'info@ordermotion.com', address.email
    assert_equal '9327 Marfield Rd Summerville, SC 29483-8643', address.full_address
    
    # Flag Data
    flags = customer.flags
    assert_equal 3, flags.count
    assert_equal 'NoAVS', flags.last.name
    assert_equal 'True', flags.last.value
    
    # Stats
    stats = customer.stats
    assert_equal "10/8/2004 1:56:00 PM", stats.last_order_date
    assert_equal "10/9/2004 2:31:00 PM", stats.last_contact_date
  end

  def test_customer_information_request_from_xml
    request = RubyOmx::CustomerInformationRequest.format(xml_for('CustomerInformationRequest(1.00)',200))
    assert_equal '1.00', request.version
    assert_equal 'CustomerNumber', request.udi_parameters.last.key
    assert_equal '10001', request.udi_parameters.last.value
  end

  def test_customer_information_request_to_xml
    request_attrs = { :customer_number => '10001' }
    request = @connection.build_customer_information_request(request_attrs)
    request2 = RubyOmx::CustomerInformationRequest.format(xml_for('CustomerInformationRequest(1.00)',200))
    assert_equal request.to_xml.to_s, request2.to_xml.to_s
  end

  def test_send_customer_information_request
    @connection.stubs(:post).returns(xml_for('CustomerInformationResponse(1.00)',200))
    response = @connection.get_customer_info({ :customer_number => '10001' })

    assert_kind_of CustomerInformationResponse, response
    assert_equal '10001', response.customer_number

    # Billing Address
    assert_equal '251 W 30th St', response.bill_to.addr1
    assert_equal 'SUITE 12E', response.bill_to.addr2
    assert_equal '1', response.bill_to.title_code
    assert_equal '', response.bill_to.company
    assert_equal 'Patrick', response.bill_to.first_name
    assert_equal 'Puck', response.bill_to.last_name
    assert_equal '251 W 30th St', response.bill_to.street1
    assert_equal '', response.bill_to.street2
    assert_equal 'New York', response.bill_to.city
    assert_equal 'NY', response.bill_to.state
    assert_equal '10001', response.bill_to.zip
    assert_equal 'US', response.bill_to.tld
    assert_equal '', response.bill_to.phone_number
    assert_equal 'pmp@ordermotion.com', response.bill_to.email
    assert_equal '', response.bill_to.house_number
    assert_equal '', response.bill_to.sub_city
    assert_equal '', response.bill_to.building

    # Flag Data
    assert_equal 4, response.flags.count
    assert_equal 'DoNotEmail', response.flags[2].name
    assert_equal 'False', response.flags[2].value

    # Custom Fields
    assert_equal 2, response.custom_fields.count
    assert_equal 'PreferencedColors', response.custom_fields[1].field_name
    assert_equal '20016', response.custom_fields[1].field_id
    assert_equal ['Red', 'Blue'], response.custom_fields[1].values
  end
  
  def test_customer_history_request_from_xml
     request = RubyOmx::CustomerHistoryRequest.format(xml_for('CustomerHistoryRequest(2.00)',200))
     assert_equal '2.00', request.version
     assert_equal true, request.udi_parameters.collect{|udi_param| [udi_param.key, udi_param.value] }.include?(["CustomerNumber", "24603"])
     assert_equal true, request.udi_parameters.collect{|udi_param| [udi_param.key, udi_param.value] }.include?(["Level", "2"])
     assert_equal true, request.udi_parameters.collect{|udi_param| [udi_param.key, udi_param.value] }.include?(["MaxOrders", "10"])
     assert_equal true, request.udi_parameters.collect{|udi_param| [udi_param.key, udi_param.value] }.include?(["FromOrderNumber", "11512"])
   end

   def test_customer_history_request_to_xml
     request_attrs = { :customer_number => '24603', :level => '2', :max_orders => '10', :from_order_number => '11512' }
     request = @connection.build_customer_history_request(request_attrs)
     request2 = RubyOmx::CustomerHistoryRequest.format(xml_for('CustomerHistoryRequest(2.00)',200))
     assert_equal request.to_xml.to_s, request2.to_xml.to_s
   end

   def test_send_customer_history_request
     @connection.stubs(:post).returns(xml_for('CustomerHistoryResponse(2.00)',200))
     response = @connection.purchase_history({ :customer_number => '24603', :level => '2', :max_orders => '10', :from_order_number => '11512' })

     assert_kind_of CustomerHistoryResponse, response
     assert_equal '1', response.success
     assert_equal '11552', response.customer_number
     assert_equal 10, response.orders.count

     # Orders
     order = response.orders.first
     assert_equal '24603', order.order_number
     assert_equal 2, order.line_items.count
     
     # Line Items
     line_item = order.line_items.first
     assert_equal '1', line_item.line_number
     assert_equal 'APPLE', line_item.item_code
     assert_equal 'Deluxe Princess Fiona', line_item.product_name
     assert_equal 1, line_item.quantity
     assert_equal '49.50', line_item.price
     assert_equal '0.00', line_item.line_discount
     assert_equal '49.50', line_item.total_price
     assert_equal '4.14562', line_item.tax
     assert_equal 8.3750, line_item.tax_percent
     assert_equal '4', line_item.line_status.value
     assert_equal '5/31/2010 5:36:00 AM', line_item.line_status.date
     assert_equal 'OK', line_item.line_status.text
     assert_equal '24603-0', line_item.shipment_number
     assert_equal 10, line_item.line_cogs
   end
end
