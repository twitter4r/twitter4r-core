class Twitter::Client
  @@STATUS_URIS = {
  	:get => '/statuses/show.json',
  	:post => '/statuses/update.json',
  	:delete => '/statuses/destroy.json',
  	:reply => '/statuses/update.json'
  }
  
  # Provides access to individual statuses via Twitter's Status APIs
  # 
  # <tt>action</tt> can be of the following values:
  # * <tt>:get</tt> to retrieve status content.  Assumes <tt>value</tt> given responds to :to_i message in meaningful way to yield intended status id.
  # * <tt>:post</tt> to publish a new status
  # * <tt>:delete</tt> to remove an existing status.  Assumes <tt>value</tt> given responds to :to_i message in meaningful way to yield intended status id.
  # * <tt>:reply</tt> to reply to an existing status.  Assumes <tt>value</tt> given is <tt>Hash</tt> which contains <tt>:in_reply_to_status_id</tt> and <tt>:status</tt>
  # 
  # <tt>value</tt> should be set to:
  # * the status identifier for <tt>:get</tt> case
  # * the status text message for <tt>:post</tt> case
  # * none necessary for <tt>:delete</tt> case
  # 
  # Examples:
  #  twitter.status(:get, 107786772)
  #  twitter.status(:post, "New Ruby open source project Twitter4R version 0.2.0 released.")
  #  twitter.status(:delete, 107790712)
  #  twitter.status(:reply, :in_reply_to_status_id => 1390482942342, :status => "@t4ruby This new v0.7.0 release is da bomb! #ruby #twitterapi #twitter4r")
  #  twitter.status(:post, "My brand new status in all its glory here tweeted from Greenwich (the real one). #withawesomehashtag #booyah", :lat => 0, :long => 0)
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:get+
  # * +:post+
  # * +:delete+
  #
  # The third argument +options+ sends on a Hash to the Twitter API with the following keys allowed:
  # * +:lat+ - latitude (for posting geolocation)
  # * +:long+ - longitude (for posting geolocation)
  # * +:place_id+ - using a place ID give by geo/reverse_geocode
  # * +:display_coordinates+ - whether or not to put a pin in the exact coordinates
  def status(action, value = nil)
    return self.timeline_for(action, value || {}) if :replies == action
    raise ArgumentError, "Invalid status action: #{action}" unless @@STATUS_URIS.keys.member?(action)
    return nil unless value
    uri = @@STATUS_URIS[action]
    response = nil
    case action
    when :get
      response = rest_oauth_connect(:get, uri, {:id => value.to_i})
    when :post
      if value.is_a?(Hash)
        params = value.delete_if { |k, v|
          ![:status, :lat, :long, :place_id, :display_coordinates].member?(k)
        }
      else
        params = {:status => value}
      end
      response = rest_oauth_connect(:post, uri, params.merge(:source => self.class.config.source))
    when :delete
      response = rest_oauth_connect(:delete, uri, {:id => value.to_i})
    when :reply
      return nil if (!value.is_a?(Hash) || !value[:status] || !value[:in_reply_to_status_id])
      params = value.merge(:source => self.class.config.source)
      response = rest_oauth_connect(:post, uri, params)
    end
    bless_model(Twitter::Status.unmarshal(response.body))
  end
end
