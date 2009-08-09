require 'evma_httpserver'
require 'erb'

module SnoopLogg
  class Server < EventMachine::Connection
    include EM::HttpServer
    
    def post_init
      super
      no_environment_strings
    end
    
    def process_http_request
      # the http request details are available via the following instance variables:
      #   @http_protocol
      #   @http_request_method
      #   @http_cookie
      #   @http_if_none_match
      #   @http_content_type
      #   @http_path_info
      #   @http_request_uri
      #   @http_query_string
      #   @http_post_content
      #   @http_headers
      
      status, headers, body = call
      
      response = EM::DelegatedHttpResponse.new(self)
      response.status = status
      response.headers = headers
      response.content_type 'text/html'
      response.content = body.to_s
      response.send_response
    end
    
    def call
      case @http_path_info
      when %r{/}
        [200, {}, all_entries]
      when %r{/(\d+)}
        [200, {}, show_entry($1.to_i)]
      when %r{/signatures/(.+)}
        [200, {}, show_entries_for_signature($1.to_s)]
      else
        [404, {}, "Not Found"]
      end
    end
    
    def all_entries
      @entries = SnoopLogg.log
      render :index
    end
    
    def show_entry(index)
      @entries = SnoopLogg.log[index]
      render :show
    end
    
    def show_entries_for_signature(sig)
      @entries = SnoopLogg.log.select{ |(s, _, _)| s == sig }
      render :index
    end
    
    module Helpers
      
      def render(action, options = {})
        options = {:layout => true}.merge(options)
        if options.delete(:layout)
          with_layout do
            erb action
          end
        else
          erb action
        end
      end
      
      def erb(template)
        ERB.new(File.read(File.join(File.dirname(__FILE__), 'server', "#{template.to_s}.erb"))).result(binding)
      end
      def with_layout(layout = :application)
        ERB.new(File.read(File.join(File.dirname(__FILE__), 'server', 'layouts', "#{layout.to_s}.erb"))).result(binding)
      end
      
      def signature_link(sig)
        <<-"end;"
          <a href="/signatures/#{sig}" title="#{sig}">#{sig[0..8]}</a>
        end;
      end
      
      def format_for_display(data)
        data.gsub!(/\\n/, "\n")
        data.gsub!(/</, "&lt;")
        data.gsub!(/>/, "&gt;")
        data
      end
      
    end
    include Helpers
    
  end
end
