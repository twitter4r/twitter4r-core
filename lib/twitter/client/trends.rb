class Twitter::Client
  @@TRENDS_URIS = {
    :locations => '/trends/available.json',
    :global => '/trends.json',
    :current => '/trends/current.json',
    :daily => '/trends/daily.json',
    :weekly => '/trends/weekly.json',
    :local => '/trends/',
  }

  # Provides access to the Twitter list trends API.
  # 
  # By default you will receive top ten topics that are trending on Twitter.
  def trends(type = :global)
    uri = @@TRENDS_URIS[type]
    response = rest_oauth_connect(:get, uri)
    if type === :locations
      bless_models(Twitter::Location.unmarshal(response.body))
    else
      bless_models(Twitter::Trendline.unmarshal(response.body))
    end
  end
end
