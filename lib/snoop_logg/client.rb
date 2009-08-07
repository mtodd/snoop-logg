require 'highline'

module SnoopLogg
  class Client < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    
    def post_init
      @handler = HighLine.new
    end
    
    def receive_line line
      case line.downcase
      when "l", "list"
        # show a list of all the recent logs
      when /s(how)? .+/
        # show a given entry
        @handler.say <<-"end;"
          ===
          #{rand}
        end;
      else
        # usage
      end
    end
    
  end
end
