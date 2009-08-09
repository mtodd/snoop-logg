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
        [200, {}, list_logs]
      when %r{/show/(\d+)}
        [200, {}, show_log($1.to_i)]
      else
        [404, {}, "Not Found"]
      end
    end
    
    def list_logs
      @logs = SnoopLogg.log
      ERB.new(File.read(File.join(File.dirname(__FILE__), 'server', 'index.erb'))).result(binding)
    end
    
    def show_log(index)
      @log = SnoopLogg.log[index]
      ERB.new(File.read(File.join(File.dirname(__FILE__), 'server', 'show.erb'))).result(binding)
    end
    
  end
end
