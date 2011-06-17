require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Twitter::Client, "#trends" do
  before(:each) do
    @uri = '/trends.json'
    @request = mas_net_http_get
    @twitter = client_context
    @default_header = @twitter.send(:http_header)
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    @favorites = []
    Twitter::Status.stub!(:unmarshal).and_return(@favorites)
  end
  
  it "should create expected HTTP GET request when not giving options" do
    @twitter.should_receive(:rest_oauth_connect).with(:get, @uri).and_return(@response)
    @twitter.trends
  end
  
  it "should raise Twitter::RESTError when 401 HTTP response received without giving options" do
    @connection = mas_net_http(mas_net_http_response(:not_authorized))
    lambda {
      @twitter.trends
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 401 HTTP response received" do
    @connection = mas_net_http(mas_net_http_response(:not_authorized))
    lambda {
      @twitter.trends
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 403 HTTP response received" do
    @connection = mas_net_http(mas_net_http_response(:forbidden))
    lambda {
      @twitter.trends
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 500 HTTP response received" do
    @connection = mas_net_http(mas_net_http_response(:server_error))
    lambda {
      @twitter.trends
    }.should raise_error(Twitter::RESTError)
  end
  
  after(:each) do
    nilize(@uri, @request, @twitter, @default_header, @response, @error_response, @connection)
  end
end
