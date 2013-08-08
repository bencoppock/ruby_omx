require 'test_helper'

class CustomersTest < MiniTest::Unit::TestCase
  def setup
    @config = YAML.load_file( File.join(File.dirname(__FILE__), 'test_config.yml') )['test']
    @connection = RubyOmx::Base.new(@config)
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
end
