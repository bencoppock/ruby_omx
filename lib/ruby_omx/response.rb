module RubyOmx

  # ErrorData appears in responses
  class Error < Node
    xml_name 'Error'
    xml_accessor :error_id, :from=>'@errorID'
    xml_accessor :error_severity, :from=>'@errorSeverity'
    xml_accessor :error_detail_0, :from=>'@errorDetail0'
    xml_accessor :error_detail_1, :from=>'@errorDetail1'
    xml_accessor :message, :from=>:content
    
    def to_s
      "#{error_id}: #{error_severity} #{error_detail_0} #{error_detail_1} #{message}"
    end
  end

  class Response < Node
    include ROXML
    xml_convention :camelcase
    
    # This is the factoryish method that is called!, not new
    def self.format(response)
      if response.content_type =~ /xml/ || response.body =~ /<?xml/
        parse_xml(response)  
      else
        response.body
      end
    end
      
    def self.parse_xml(response)
      if [Net::HTTPClientError, Net::HTTPServerError].any? {|error| response.is_a? error }
        puts "ERROR: #{response} -- #{response.body}"
        return ResponseError.from_xml(response.body)
      else
        return self.from_xml(response.body)
      end
    end
  end

  class Item < Node
    xml_name "Item"
    xml_accessor :item_code, :from=>'@itemCode'
  end    

  class LineStatus < Node
    xml_name "LineStatus"
    #<LineStatus date="2/9/2006 2:47:00 PM" text="OK">40</LineStatus>
    xml_reader :text, :from => '@text'  # C/L means cancelled, OK with a date means processing
    xml_reader :date, :from => "@date" # reverting to string as date is invalid, cancellation date if cancelled, processing date if processing
    xml_reader :value, :from => :content
  end

  # LineItems appear in requests and responses
  class LineItem < Node
    xml_name "LineItem"
    xml_accessor :line_number, :from => '@lineNumber'
    xml_accessor :item_code
    xml_accessor :quantity, :as => Integer
    xml_accessor :unit_price
    xml_accessor :price
    xml_accessor :update_standard_price  # default to 'False'
    xml_accessor :cancel_line

    # read only attributes that come in the response
    xml_reader :product_name
    xml_reader :line_status, :as=>LineStatus
    xml_reader :warehouse_reference
    xml_reader :tracking_number
    xml_reader :shipment_number
    xml_reader :line_cogs, :from=>'LineCOGS', :as=>Float
    xml_reader :unit_cogs, :from=>'UnitCOGS', :as=>Float
    xml_reader :supplier_item_code
  end
    
  class CustomItemAttribute < Node
    xml_name "Attribute"
    xml_reader :attribute_id, :from => '@attributeID'
    xml_reader :name, :from => '@name'
    xml_reader :value, :from => :content
  end

  class Address < Node
    xml_name "Address"
    xml_accessor :address_type, :from => '@type'
    xml_accessor :title_code, :company, :firstname, :lastname, :address1, :address2, :county, :city, :state, :phone_number, :email, :country
    xml_accessor :zip, :from => 'ZIP'
    xml_accessor :tld, :from => 'TLD'
  end

  class StandardResponse < Response
    xml_reader :success
	  xml_reader :errors, :as=>[Error], :in=>'ErrorData'

    def to_s
      error_string = self.errors.collect{ |e| e.message.to_s }.join(',')
      return "success: #{success}, errors: #{error_string}"
    end
  end
  
end
