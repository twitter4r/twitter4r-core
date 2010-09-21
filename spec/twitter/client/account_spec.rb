require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Twitter::Client, "#account_info" do
  before(:each) do
    @uri = Twitter::Client.class_eval("@@ACCOUNT_URIS[:rate_limit_status]")
    @request = mas_net_http_get
    @twitter = client_context
    @default_header = @twitter.send(:http_header)
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    @response.stub!(:body).and_return("{}")
    @rate_limit_status = mock(Twitter::RateLimitStatus)
    @twitter.stub!(:bless_models).and_return({})
  end

  it "should create expected HTTP GET request" do
    @twitter.should_receive(:rest_oauth_connect).with(:get, @uri).and_return(@response)
    @twitter.account_info
  end

  it "should raise Twitter::RESTError when 500 HTTP response received when giving page options" do
    @connection = mas_net_http(mas_net_http_response(:server_error))
    lambda {
      @twitter.account_info
    }.should raise_error(Twitter::RESTError)
  end
end
