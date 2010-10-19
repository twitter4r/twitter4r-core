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
      uri = rest_request_uri(path, params)
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
      uri = search_request_uri(path, params)
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
      unless @rest_consumer
        consumer = @oauth_consumer
        if consumer
          key = consumer[:key] || consumer["key"]
          secret = consumer[:secret] || consumer["secret"]
        end
        cfg = self.class.config
        key ||= cfg.oauth_consumer_token
        secret ||= cfg.oauth_consumer_secret
        @rest_consumer = OAuth::Consumer.new(key, secret, 
                                             :site => construct_site_url,
                                             :proxy => construct_proxy_url)
        http = @rest_consumer.http
        http.read_timeout = cfg.timeout
      end
      @rest_consumer
    end

    def rest_access_token
      unless @rest_access_token
        access = @oauth_access
        if access
          key = access[:key] || access["key"]
          secret = access[:secret] || access["secret"]
        else
          key = ""
          secret = ""
        end
        @rest_access_token = OAuth::AccessToken.new(rest_consumer, key, secret)
      end
      @rest_access_token
    end
    
    def search_consumer
      unless @search_consumer
        cfg = self.class.config
        consumer = @oauth_consumer
        if consumer
          key = consumer[:key] || consumer["key"] 
          secret = consumer[:secret] || consumer["secret"]
        end
        cfg = self.class.config
        key ||= cfg.oauth_consumer_token
        secret ||= cfg.oauth_consumer_secret
        @search_consumer = OAuth::Consumer.new(key, secret, 
                                               :site => construct_site_url(:search),
                                               :proxy => construct_proxy_url)
        http = @search_consumer.http
        http.read_timeout = cfg.timeout
      end
      @search_consumer
    end

    def search_access_token
      unless @search_access_token
        key = @oauth_access[:key] || @oauth_access["key"]
        secret = @oauth_access[:secret] || @oauth_access["secret"]
        @search_access_token = OAuth::AccessToken.new(search_consumer, key, secret)
      end
      @search_access_token
    end

    def raise_rest_error(response, uri = nil)
      map = JSON.parse(response.body)
      error = Twitter::RESTError.registry[response.code]
      raise error.new(:code => response.code, 
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
      	'User-Agent' => "Twitter4R v#{Twitter::Version.to_version} [#{self.class.config.user_agent}]",
      	'Accept' => 'text/x-json',
      	'X-Twitter-Client' => self.class.config.application_name,
      	'X-Twitter-Client-Version' => self.class.config.application_version,
      	'X-Twitter-Client-URL' => self.class.config.application_url,
      }
      @@http_header
    end

    def rest_request_uri(path, params = nil)
      uri = "#{self.class.config.path_prefix}#{path}"
      uri << "?#{params.to_http_str}" if params
      uri
    end
    
    def search_request_uri(path, params = nil)
      uri = "#{self.class.config.search_path_prefix}#{path}"
      uri << "?#{params.to_http_str}" if params
      uri
    end
    
    def uri_components(service = :rest)
      case service
      when :rest
        return self.class.config.protocol, self.class.config.host, self.class.config.port, 
          self.class.config.path_prefix
      when :search
        return self.class.config.search_protocol, self.class.config.search_host, 
          self.class.config.search_port, self.class.config.search_path_prefix
      end
    end

    def construct_site_url(service = :rest)
      protocol, host, port, path_prefix = uri_components(service)
      "#{(protocol == :ssl ? :https : protocol).to_s}://#{host}:#{port}"
    end

    def construct_proxy_url
      cfg = self.class.config
      proxy_user, proxy_pass = cfg.proxy_user, cfg.proxy_pass
      proxy_host, proxy_port = cfg.proxy_host, cfg.proxy_port
      protocol = ((cfg.proxy_protocol == :ssl) ? :https : cfg.proxy_protocol).to_s
      url = nil
      if proxy_host
        url = "#{protocol}://"
        if proxy_user
          url << "#{proxy_user}:#{proxy_pass}@"
        end
        url << "#{proxy_host}:#{proxy_port.to_s}"
      else
        url
      end
    end
end
