class Twitter::Client
  @@ACCOUNT_URIS = {
    :rate_limit_status => '/account/rate_limit_status',
  }
  
  # Provides access to the Twitter rate limit status API.
  # 
  # You can find out information about your account status.  Currently the only 
  # supported type of account status is the <tt>:rate_limit_status</tt> which 
  # returns a <tt>Twitter::RateLimitStatus</tt> object.
  # 
  # Example:
  #  account_status = client.account_info
  #  puts account_status.remaining_hits
  def account_info(type = :rate_limit_status)
    response = rest_oauth_connect(:get, @@ACCOUNT_URIS[type])
    bless_models(Twitter::RateLimitStatus.unmarshal(response.body))
  end
end
