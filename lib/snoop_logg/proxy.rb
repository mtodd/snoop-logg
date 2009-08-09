module SnoopLogg
  class Proxy < EventMachine::Connection
    
    attr_accessor :destination
    
    def initialize(options)
      self.destination = EventMachine.connect(options[:forward_server], options[:forward_port], Forwarder, self)
    end
    
    def post_init
      logger.debug "new connection #{@signature}"
    end
    
    def receive_data request
      # log request payload
      SnoopLogg.log.record @signature, :request, request
      self.destination.send_data request
    end
    
    def unbind
      logger.debug "connection #{@signature} closed"
    end
    
    class Forwarder < EventMachine::Connection
      
      attr_accessor :source
      
      def initialize(source)
        self.source = source
      end
      
      def receive_data response
        # log response payload
        SnoopLogg.log.record @signature, :response, response
        self.source.send_data response
      end
      
    end
    
  end
end
