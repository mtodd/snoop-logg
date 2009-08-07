require 'evma_httpserver'

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
      
      response = EM::DelegatedHttpResponse.new(self)
      response.status = 200
      response.content_type 'text/html'
      response.content = '<center><h1>Hi there</h1></center>'
      response.send_response
    end
    
  end
end
