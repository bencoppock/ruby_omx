module RubyOmx

  # UDI Parameters are included in every OMX request
  class UDIParameter < Node
    xml_name "Parameter"
    xml_accessor :key, :from => '@key'
    xml_accessor :value, :from => :content
  end

  class Request < Response

    def initialize(attrs=nil)
      self.udi_parameters = [UDIParameter.new({:key=>'UDIAuthToken', :value=>attrs.delete(:udi_auth_token)})]
      super
			raw_xml = attrs[:raw_xml] ||= false
   end

   attr_accessor :raw_xml
   xml_accessor :udi_parameters, :as => [UDIParameter], :in => 'UDIParameter'
   xml_accessor :version, :from => '@version'
  end

end
