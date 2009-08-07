require 'optparse'
require 'uri'

module SnoopLogg
  class Runner
    
    attr_accessor :options
    
    def self.run!(args)
      new(args).run!
    end
    
    def initialize(args)
      self.options = SnoopLogg.options.dup
      
      # TODO: parse commandline options
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: snoop-logger [options] listen:port forward:port"
        opts.on("-p", "--port PORT", "server logs on PORT (default: #{self.options[:port]})"){ |port| self.options[:port] = port.to_i }
      end
      @parser.parse! args
      
      self.options[:listen_server], self.options[:listen_port] = args.shift.split(':')
      self.options[:forward_server], self.options[:forward_port] = args.shift.split(':')
    end
    
    def run!
      EventMachine::run do
        # Start Listener
        EventMachine.start_server(self.options[:listen_server], self.options[:listen_port], Proxy, self.options)
        logger.debug "Now listening on %s:%i..." % [self.options[:listen_server], self.options[:listen_port]]
        
        # Start Web Server
        EventMachine.start_server("127.0.0.1", self.options[:port], Server)
        logger.debug "Now serving logs on 127.0.0.1:%i..." % self.options[:port]
        
        if self.options[:enable_client]
          # Start CLI Client
          EventMachine.open_keyboard(Client)
          logger.debug "Now serving logs on 127.0.0.1:%i..." % self.options[:port]
        end
      end
    end
    
  end
end
