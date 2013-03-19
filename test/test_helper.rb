# encoding: utf-8
require 'simplecov'
SimpleCov.start do
  add_filter 'test'
end

require 'minitest/autorun'
require 'pathname'
require 'yaml'
require 'mocha'
require File.join(File.dirname(__FILE__), '..', 'lib', 'ruby_omx')

include RubyOmx

def xml_raw(name)
  file = File.open(Pathname.new(File.dirname(__FILE__)).expand_path.dirname.join("examples/xml/#{name}.xml"),'rb')
  file.read
end

def xml_for(name, code)
  mock_response(code, {:content_type=>'text/xml', :body=>xml_raw(name)})
end

def xml_for_raw(xml, code)
  mock_response(code, {:content_type=>'text/xml', :body=>xml})
end

def mock_response(code, options={})
  body = options[:body]
  content_type = options[:content_type]
  response = Net::HTTPResponse.send(:response_class, code.to_s).new("1.0", code.to_s, "message")
  response.instance_variable_set(:@body, body)
  response.instance_variable_set(:@read, true)
  response.content_type = content_type
  return response
end

