# The Twitter4R API provides a nicer Ruby object API to work with 
# instead of coding around the REST API.

# Module to encapsule the Twitter4R API.
module Twitter
  # Mixin module for classes that need to have a constructor similar to
  # Rails' models, where a <tt>Hash</tt> is provided to set attributes
  # appropriately.
  # 
  # To define a class that uses this mixin, use the following code:
  #  class FilmActor
  #    include ClassUtilMixin
  #  end
  module ClassUtilMixin #:nodoc:
    def self.included(base) #:nodoc:
      base.send(:include, InstanceMethods)
    end
    
    # Instance methods defined for <tt>Twitter::ModelMixin</tt> module.
    module InstanceMethods #:nodoc:
      # Constructor/initializer that takes a hash of parameters that 
      # will initialize *members* or instance attributes to the 
      # values given.  For example,
      # 
      #  class FilmActor
      #    include Twitter::ClassUtilMixin
      #    attr_accessor :name
      #  end
      #  
      #  class Production
      #    include Twitter::ClassUtilMixin
      #    attr_accessor :title, :year, :actors
      #  end
      #  
      #  # Favorite actress...
      #  jodhi = FilmActor.new(:name => "Jodhi May")
      #  jodhi.name # => "Jodhi May"
      #  
      #  # Favorite actor...
      #  robert = FilmActor.new(:name => "Robert Lindsay")
      #  robert.name # => "Robert Lindsay"
      #  
      #  # Jane is also an excellent pick...gotta love her accent!
      #  jane = FilmActor.new(name => "Jane Horrocks")
      #  jane.name # => "Jane Horrocks"
      #  
      #  # Witty BBC series...
      #  mrs_pritchard = Production.new(:title => "The Amazing Mrs. Pritchard", 
      #                                 :year => 2005, 
      #                                 :actors => [jodhi, jane])
      #  mrs_pritchard.title  # => "The Amazing Mrs. Pritchard"
      #  mrs_pritchard.year   # => 2005
      #  mrs_pritchard.actors # => [#<FilmActor:0xb79d6bbc @name="Jodhi May">, 
      #  <FilmActor:0xb79d319c @name="Jane Horrocks">]
      #  # Any Ros Pritchard's out there to save us from the Tony Blair
      #  # and Gordon Brown *New Labour* debacle?  You've got my vote! 
      #  
      #  jericho = Production.new(:title => "Jericho", 
      #                           :year => 2005, 
      #                           :actors => [robert])
      #  jericho.title   # => "Jericho"
      #  jericho.year    # => 2005
      #  jericho.actors  # => [#<FilmActor:0xc95d3eec @name="Robert Lindsay">]
      # 
      # Assuming class <tt>FilmActor</tt> includes 
      # <tt>Twitter::ClassUtilMixin</tt> in the class definition 
      # and has an attribute of <tt>name</tt>, then that instance 
      # attribute will be set to "Jodhi May" for the <tt>actress</tt> 
      # object during object initialization (aka construction for 
      # you Java heads).
      def initialize(params = {})
        params.each do |key,val|
          self.send("#{key}=", val) if self.respond_to? key
        end
        self.send(:init) if self.respond_to? :init
      end
      
      protected
        # Helper method to provide an easy and terse way to require 
        # a block is provided to a method.
        def require_block(block_given)
          raise ArgumentError, "Must provide a block" unless block_given
        end
    end
  end # ClassUtilMixin
  
  # Exception API base class raised when there is an error encountered upon 
  # querying or posting to the remote Twitter REST API.
  # 
  # To consume and query any <tt>RESTError</tt> raised by Twitter4R:
  #  begin
  #    # Do something with your instance of <tt>Twitter::Client</tt>.
  #    # Maybe something like:
  #    timeline = twitter.timeline_for(:public)
  #  rescue RESTError => re
  #    puts re.code, re.message, re.uri
  #  end
  # Which on the code raising a <tt>RESTError</tt> will output something like:
  #  404
  #  Resource Not Found
  #  /i_am_crap.json
  class RESTError < RuntimeError 
    class << self
      @@REGISTRY = {}

      def registry
        @@REGISTRY
      end

      def register(status_code)
        @@REGISTRY[status_code] = self
      end
    end

    include ClassUtilMixin
    @@ATTRIBUTES = [:code, :message, :uri, :error]
    attr_accessor :code, :message, :uri, :error
    
    # Returns string in following format:
    #  "HTTP #{@code}: #{@message} at #{@uri}"
    # For example,
    #  "HTTP 404: Resource Not Found at /i_am_crap.json
    #     >This is the error message sent back by the Twitter.com API"
    def to_s
      "HTTP #{@code}: #{@message} at #{@uri}"
    end
  end # RESTError

  # Runtime error leaf class raised when Twitter.com API has no new results 
  # to return from the last query. HTTP code: 304 (aka Not Modified).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue NotModifiedError => nme
  #    timeline = []
  #  end
  class NotModifiedError < RESTError; register('304'); end
  
  # Runtime error leaf class raised when client has reached rate limits.
  # HTTP code: 400 (aka Bad Request).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue RateLimitError => rlre
  #    # do something here...
  #  end
  class RateLimitError < RESTError; register('400'); end
  
  # Runtime error leaf class raised when user and/or client credentials 
  # are missing or invalid. 
  # HTTP code: 401 (aka Unauthorized).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue UnauthorizedError => uae
  #    # do something to prompt for valid credentials to user here.
  #  end
  class UnauthorizedError < RESTError; register('401'); end
  
  # Runtime error leaf class raised when update limit reached. 
  # HTTP code: 403 (aka Forbidden).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue ForbiddenError => fe
  #    # do something to notify user that update limit has been reached
  #  end
  class ForbiddenError < RESTError; register('403'); end
  
  # Runtime error leaf class raised when a resource requested was not found.
  # HTTP code: 404 (aka Not Found).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue NotFoundError => nfe
  #    # do something to notify user that resource was not found.
  #  end
  class NotFoundError < RESTError; register('404'); end
  
  # Runtime error leaf class raised when the format specified in the request
  # is not understood by the Twitter.com API. 
  # HTTP code: 406 (aka Not Acceptable).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue NotAcceptableError => nae
  #    # 
  #  end
  class NotAcceptableError < RESTError; register('406'); end
  
  # Runtime error leaf class raised when search rate limit reached.
  # HTTP code: 420.
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue SearchRateLimitError => nme
  #    # 
  #  end
  class SearchRateLimitError < RESTError; register('420'); end
  
  # Runtime error leaf class raised when Twitter.com API is borked for 
  # an unknown reason.
  # HTTP code: 500 (aka Internal Server Error).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue InternalServerError => ise
  #    # do something to notify user that an unknown internal server error
  #    # has arisen.
  #  end
  class InternalServerError < RESTError; register('500'); end
  
  # Runtime error leaf class raised when Twitter.com servers are being 
  # upgraded.
  # HTTP code: 502 (aka Bad Gateway).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue BadGatewayError => bge
  #    #
  #  end
  class BadGatewayError < RESTError; register('502'); end
 
  # Runtime error leaf class raised when Twitter.com servers are unable 
  # to respond to the current load.
  # HTTP code: 502 (aka Service Unavailable).
  #
  # To handle specifically you would do the following:
  #  begin
  #    timeline = twitter.timeline_for(:friends, :since => tweet)
  #  rescue ServiceUnavailableError => sue
  #    #
  #  end
  class ServiceUnavailableError < RESTError; register('503'); end
end
