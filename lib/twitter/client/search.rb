class Twitter::Client
  @@SEARCH_URIS = {
    :basic => "/search.json",
  }

  # Provides access to Twitter's Search API.
  # 
  # Example:
  #  # For keyword search
  #  iterator = @twitter.search(:q => "coworking")
  #  while (tweet = iterator.next)
  #    puts tweet.text
  #  end
  # 
  # All options will be passed on to the Twitter.com Search REST API
  def search(options = {})
    uri = @@SEARCH_URIS[:basic]
    response = search_oauth_connect(:get, uri, options)
    json = JSON.parse(response.body)
    bless_models(Twitter::Status.unmarshal(JSON.dump(json["results"])))
  end
end
