class Twitter::Client
  @@FRIEND_URIS = {
    :add => '/friendships/create',
    :remove => '/friendships/destroy',
  }

  @@FRIENDSHIP_URIS = {
    :incoming => '/friendships/incoming.json',
    :outgoing => '/friendships/outgoing.json',
  }
	
  # Provides access to the Twitter Friendship API.
  # 
  # You can add and remove friends using this method.
  # 
  # <tt>action</tt> can be any of the following values:
  # * <tt>:add</tt> - to add a friend, you would use this <tt>action</tt> value
  # * <tt>:remove</tt> - to remove an existing friend from your friends list use this.
  # 
  # The <tt>value</tt> must be either the user to befriend or defriend's 
  # screen name, integer unique user ID or Twitter::User object representation.
  # 
  # Examples:
  #  screen_name = 'dictionary'
  #  client.friend(:add, 'dictionary')
  #  client.friend(:remove, 'dictionary')
  #  id = 1260061
  #  client.friend(:add, id)
  #  client.friend(:remove, id)
  #  user = Twitter::User.find(id, client)
  #  client.friend(:add, user)
  #  client.friend(:remove, user)
  def friend(action, value)
    raise ArgumentError, "Invalid friend action provided: #{action}" unless @@FRIEND_URIS.keys.member?(action)
    value = value.to_i unless value.is_a?(String)
    uri = "#{@@FRIEND_URIS[action]}/#{value}.json"
    response = rest_oauth_connect(:post, uri)
    bless_model(Twitter::User.unmarshal(response.body))
  end

  # Provides friendship information for the following scenarios:
  # * <tt>:incoming</tt> - returns an array of numeric IDs for every user who has a pending request to follow the authenticating user.
  # * <tt>:outgoing</tt> - returns an array of numeric IDs for every protected user for whom the authenticating user has a pending follow request.
  #
  # Examples:
  #  client.friendships(:incoming) 
  #  #=> { :id_list => { :ids => [30592818, 21249843], :next_cursor => 1288724293877798413, :previous_cursor => -1300794057949944903 }}
  def friendships(action)
    raise ArgumentError, "Invalid friend action provided: #{action}" unless @@FRIENDSHIP_URIS.keys.member?(action)
    uri = @@FRIENDSHIP_URIS[action]
    response = rest_oauth_connect(:get, uri)
    JSON.parse(response.body)
  end
end
