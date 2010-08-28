class Twitter::Client
  alias :old_inspect :inspect

  def inspect
    s = old_inspect
    s.gsub!(/@password=".*?"/, '@password="XXXX"')
    s.gsub!(/"secret"=>".*?"/, '"secret"=>"XXXX"')
    s
  end

  protected
    attr_accessor :login, :password, :oauth_consumer, :oauth_access

    def credentials_given?
      !!(@login && @password)
    end
    
    # Returns the response of the OAuth/HTTP(s) connection.
    def oauth_connect(body = nil, require_auth = true, service = :reset, &block)
      require_block(block_given?)
      
      
    end

    # Returns the response of the HTTP connection.  
    def http_connect(body = nil, require_auth = true, service = :rest, &block)
    	require_block(block_given?)
    	connection = create_http_connection(service)
    	connection.start do |connection|
    		req = yield connection if block_given?
    		req.basic_auth(@login, @password) if require_auth && credentials_given?
    		response = connection.request(req, body)
    		handle_rest_response(response)
    		response
      end
    end
    
    # "Blesses" model object with client information
    def bless_model(model)
    	model.bless(self) if model
    end
    
    def bless_models(list)
      return bless_model(list) if list.respond_to?(:client=)
    	list.collect { |model| bless_model(model) } if list.respond_to?(:collect)
    end
    
  private
    @@http_header = nil

    def get_consumer
      unless @consumer
        @consumer = OAuth::Consumer.new(@oauth_consumer["key"], 
                                        @oauth_consumer["secret"], 
                                        { :site => construct_site_url })
      end
      @consumer
    end

    def get_access_token
      unless @access_token
        @access_token = OAuth::AccessToken.new(get_consumer, 
                                               @oauth_access["key"], 
                                               @oauth_access["secret"])
      end
      @access_token
    end
    
    def raise_rest_error(response, uri = nil)
      map = JSON.parse(response.body)
      raise Twitter::RESTError.new(:code => response.code, 
                                   :message => response.message,
                                   :error => map["error"],
                                   :uri => uri)        
    end
    
    def handle_rest_response(response, uri = nil)
      unless response.is_a?(Net::HTTPSuccess)
        raise_rest_error(response, uri)
      end
    end
    
    def create_http_connection(service = :rest)
      protocol, host, port, path_prefix = uri_components(service)
      conn = Net::HTTP.new(host, port, 
                            @@config.proxy_host, @@config.proxy_port,
                            @@config.proxy_user, @@config.proxy_pass)
      if protocol == :ssl
        conn.use_ssl = true
        conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      conn.read_timeout = @@config.timeout
      conn
    end

    def http_header
      # can cache this in class variable since all "variables" used to 
      # create the contents of the HTTP header are determined by other 
      # class variables that are not designed to change after instantiation.
      @@http_header ||= { 
      	'User-Agent' => "Twitter4R v#{Twitter::Version.to_version} [#{@@config.user_agent}]",
      	'Accept' => 'text/x-json',
      	'X-Twitter-Client' => @@config.application_name,
      	'X-Twitter-Client-Version' => @@config.application_version,
      	'X-Twitter-Client-URL' => @@config.application_url,
      }
      @@http_header
    end
    
    def create_http_get_request(uri, params = {})
    	path = (params.size > 0) ? "#{uri}?#{params.to_http_str}" : uri
      Net::HTTP::Get.new(path, http_header)
    end
    
    def create_http_post_request(uri)
    	Net::HTTP::Post.new(uri, http_header)
    end
    
    def create_http_delete_request(uri, params = {})
    	path = (params.size > 0) ? "#{uri}?#{params.to_http_str}" : uri
    	Net::HTTP::Delete.new(path, http_header)
    end

    def uri_components(service = :rest)
      case service
      when :rest
        return @@config.protocol, @@config.host, @@config.port, @@config.path_prefix
      when :search
        return @@config.search_protocol, @@config.search_host, @@config.search_port, @@config.search_path_prefix
      end
    end

    def construct_site_url(service = :rest)
      protocol, host, port, path_prefix = uri_components(service)
      "#{protocol == :ssl ? :https : protocol}://#{host}:#{port}"
    end
end
