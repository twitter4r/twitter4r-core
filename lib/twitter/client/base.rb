class Twitter::Client
  alias :old_inspect :inspect

  def inspect
    s = old_inspect
    s.gsub!(/@password=".*?"/, '@password="XXXX"')
    s.gsub!(/"secret"=>".*?"/, '"secret"=>"XXXX"')
    s
  end

  protected
    attr_accessor :login, :oauth_consumer, :oauth_access

    # Returns the response of the OAuth/HTTP(s) request for REST API requests (not Search)
    def rest_oauth_connect(method, path, params = {}, headers = {}, require_auth = true)
      atoken = rest_access_token
      uri = rest_request_uri(path)
      if [:get, :delete].include?(method)
        response = atoken.send(method, uri, http_header.merge(headers))
      else
        response = atoken.send(method, uri, params, http_header.merge(headers))
      end
    	handle_rest_response(response)
    	response
    end

    # Returns the response of the OAuth/HTTP(s) request for Search API requests (not REST)
    def search_oauth_connect(method, path, params = {}, headers = {}, require_auth = true)
      atoken = search_access_token
      uri = search_request_uri(path)
      if method == :get
        response = atoken.send(method, uri, http_header.merge(headers))
      end
    	handle_rest_response(response)
    	response
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

    def rest_consumer
      unless @consumer
        @consumer = OAuth::Consumer.new(@oauth_consumer["key"], 
                                        @oauth_consumer["secret"], 
                                        :site => construct_site_url)
      end
      @consumer
    end

    def rest_access_token
      unless @access_token
        @access_token = OAuth::AccessToken.new(rest_consumer, 
                                               @oauth_access["key"], 
                                               @oauth_access["secret"])
      end
      @access_token
    end
    
    def search_consumer
      unless @consumer
        @consumer = OAuth::Consumer.new(@oauth_consumer["key"], 
                                        @oauth_consumer["secret"], 
                                        :site => construct_site_url(:search))
      end
      @consumer
    end

    def search_access_token
      unless @access_token
        @access_token = OAuth::AccessToken.new(search_consumer, 
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

    def rest_request_uri(path)
      "#{@@config.path_prefix}#{path}"
    end
    
    def search_request_uri(path)
      "#{@@config.search_path_prefix}#{path}"
    end
    
    def uri_components(service = :rest)
      case service
      when :rest
        return @@config.protocol, @@config.host, @@config.port, 
          @@config.path_prefix
      when :search
        return @@config.search_protocol, @@config.search_host, 
          @@config.search_port, @@config.search_path_prefix
      end
    end

    def construct_site_url(service = :rest)
      protocol, host, port, path_prefix = uri_components(service)
      "#{protocol == :ssl ? :https : protocol}://#{host}:#{port}"
    end
end
