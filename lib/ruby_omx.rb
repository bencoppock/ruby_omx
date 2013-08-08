require 'cgi'
require 'uri'
require 'openssl'
require 'net/https'
require 'time'
require 'date'
require 'base64'
require 'builder'
require "rexml/document"
require 'roxml'

$:.unshift(File.dirname(__FILE__))

require 'ruby_omx/node'
require 'ruby_omx/response'
require 'ruby_omx/request'
require 'ruby_omx/orders'
require 'ruby_omx/items'
require 'ruby_omx/purchase_orders'
require 'ruby_omx/memos'
require 'ruby_omx/customers'
Dir.glob(File.join(File.dirname(__FILE__), 'ruby_omx/response/*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'ruby_omx/request/*.rb')).each {|f| require f }

require 'ruby_omx/base'
require 'ruby_omx/version'
require 'ruby_omx/exceptions'
require 'ruby_omx/connection'

RubyOmx::Base.class_eval do
  include RubyOmx::Orders
  include RubyOmx::Items
  include RubyOmx::PurchaseOrders
  include RubyOmx::Memos
  include RubyOmx::Customers
end