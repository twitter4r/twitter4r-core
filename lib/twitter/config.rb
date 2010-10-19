# config.rb contains classes, methods and extends existing Twitter4R classes 
# to provide easy configuration facilities.

module Twitter
  # Represents global configuration for Twitter::Client.
  # Can override the following configuration options:
  # * <tt>protocol</tt> - <tt>:http</tt>, <tt>:https</tt> or <tt>:ssl</tt> supported.  <tt>:ssl</tt> is an alias for <tt>:https</tt>.  Defaults to <tt>:ssl</tt>
  # * <tt>host</tt> - hostname to connect to for the Twitter service.  Defaults to <tt>'twitter.com'</tt>.
  # * <tt>port</tt> - port to connect to for the Twitter service.  Defaults to <tt>443</tt>.
  # * <tt>path_prefix</tt> - path to prefix URIs of REST API calls.  Defaults to <tt>""</tt>.
  # * <tt>search_protocol</tt> - <tt>:http</tt>, <tt>:https</tt> or <tt>:ssl</tt> supported.  <tt>:ssl</tt> is an alias for <tt>:https</tt>.  Defaults to <tt>:ssl</tt>
  # * <tt>search_host</tt> - hostname to connect to for the Twitter Search service.  Defaults to <tt>'twitter.com'</tt>.
  # * <tt>search_port</tt> - port to connect to for the Twitter Search service.  Defaults to <tt>443</tt>.
  # * <tt>search_path_prefix</tt> - path to prefix URIs of Search API calls.  Defaults to <tt>""</tt>.
  # * <tt>proxy_protocol</tt> - proxy protocol to use.  Defaults to http.
  # * <tt>proxy_host</tt> - proxy host to use.  Defaults to nil.
  # * <tt>proxy_port</tt> - proxy host to use.  Defaults to 8080.
  # * <tt>proxy_user</tt> - proxy username to use.  Defaults to nil.
  # * <tt>proxy_pass</tt> - proxy password to use.  Defaults to nil.
  # * <tt>user_agent</tt> - user agent string to use for each request of the HTTP header.
  # * <tt>application_name</tt> - name of your client application.  Defaults to 'Twitter4R'.
  # * <tt>application_version</tt> - version of your client application.  Defaults to current <tt>Twitter::Version.to_version</tt>.
  # * <tt>application_url</tt> - URL of your client application.  Defaults to http://twitter4r.rubyforge.org.
  # * <tt>source</tt> - the source id given to you by Twitter to identify your application in their web interface.  Note: you must contact Twitter.com developer directly so they can configure their servers appropriately.
  # * <tt>timeout</tt> - the timeout in second for HTTP requests.
  # * <tt>oauth_consumer_token</tt> - the OAuth consumer token for your application
  # * <tt>oauth_consumer_secret</tt> - the OAuth consumer secret for your application
  # * <tt>oauth_request_token_path</tt> - the URI path for Twitter API's OAuth request token call. Not usually necessary to override.
  # * <tt>oauth_access_token_path</tt> - the URI path for Twitter API's OAuth access token call. Not usually necessary to override.
  # * <tt>oauth_authorize_path</tt> - the URI path for Twitter API's OAuth authorize call. Not usually necessary to override.
  class Config
    include ClassUtilMixin
    @@ATTRIBUTES = [
      :protocol, 
      :host, 
      :port, 
      :path_prefix,
      :search_protocol,
      :search_host,
      :search_port,
      :search_path_prefix,
      :proxy_protocol,
      :proxy_host, 
      :proxy_port, 
      :proxy_user, 
      :proxy_pass, 
      :user_agent,
      :application_name,
      :application_version,
      :application_url,
      :source,
      :timeout,
      :oauth_consumer_token,
      :oauth_consumer_secret,
      :oauth_request_token_path,
      :oauth_access_token_path,
      :oauth_authorize_path,
      :exception_registry,
    ]

    attr_accessor(*@@ATTRIBUTES)
    
    # Override of Object#eql? to ensure RSpec specifications run 
    # correctly. Also done to follow Ruby best practices.
    def eql?(other)
      return true if self == other
      @@ATTRIBUTES.each do |att|
        return false unless self.send(att).eql?(other.send(att))
      end
      true
    end
  end

  class Client
    @@defaults = { :host => 'twitter.com', 
                   :port => 443, 
                   :protocol => :ssl,
                   :path_prefix => "",
                   :search_host => 'search.twitter.com',
                   :search_port => 80,
                   :search_protocol => :http,
                   :search_path_prefix => "",
                   :proxy_protocol => "http",
                   :proxy_host => nil,
                   :proxy_port => 8080,
                   :user_agent => "default",
                   :application_name => 'Twitter4R',
                   :application_version => Twitter::Version.to_version,
                   :application_url => 'http://twitter4r.rubyforge.org',
                   :source => 'twitter4r',
                   :timeout => 20,
                   :oauth_request_token_path => '/oauth/request_token',
                   :oauth_access_token_path => '/oauth/access_token',
                   :oauth_authorize_path => '/oauth/authorize',
                   :exception_registry => Twitter::RESTError.registry,
    }
    @@config = Twitter::Config.new(@@defaults)

    # Twitter::Client class methods
    class << self
      # returns configuration object
      def config
        @@config
      end

      # Yields to given <tt>block</tt> to configure the Twitter4R API.
      def configure(&block)
        raise ArgumentError, "Block must be provided to configure" unless block_given?
        yield config
      end # configure
    end # class << self    
  end # Client class
end # Twitter module
