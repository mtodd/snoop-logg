$:.unshift File.dirname(__FILE__)

require 'eventmachine'

require 'snoop_logg/version'
require 'snoop_logg/logger'
require 'snoop_logg/runner'

require 'snoop_logg/proxy'

require 'snoop_logg/server'
require 'snoop_logg/client'

module SnoopLogg
  
  class << self
    attr_accessor :options, :log
  end
  @options = {
    :listen_address => "127.0.0.1",
    :listen_port => 8080,
    
    :foratward_address => "127.0.0.1",
    :forward_port => 80,
    
    :web_server_port => 4444,
    :enable_client => true,
    
    :log_file => nil,
    :log_level => 'debug'
  }
  @log = Log.new
  
end
