require 'logger'

module SnoopLogg
  
  def self.logger
    @_logger ||= begin
      logger = SnoopLogg.options[:logger] || ::Logger.new(SnoopLogg.options[:log_file] || STDOUT)
      logger.formatter = proc{|s,t,p,m|"%5s [%s] (%s) %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), $$, m]}
      logger.level = ::Logger.const_get((SnoopLogg.options[:log_level] || 'info').upcase)
      logger
    end
  end
  
  module Logger
    
    def self.included(target)
      target.extend(ClassMethods)
    end
    
    def logger
      SnoopLogg.logger
    end
    
    module ClassMethods
      def logger
        SnoopLogg.logger
      end
    end
    
  end
end

class Object
  include SnoopLogg::Logger
end
