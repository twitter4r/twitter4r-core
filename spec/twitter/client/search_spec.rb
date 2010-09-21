require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Twitter::Client, "#search" do
  before(:each) do
    @twitter = client_context
    @uris = Twitter::Client.class_eval("@@SEARCH_URIS")
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, "{\"results\": [], \"refresh_url\":\"?since_id=1768746401&q=blabla\"}")
    @connection = mas_net_http(@response)
    @statuses = []
    Twitter::Status.stub!(:unmarshal).and_return(@statuses)
    @page = 2
    @keywords = "twitter4r"
    @to = "SusanPotter"
    @from = "twitter4r"
  end
  
  it "should create expected HTTP GET request using :to" do
    @twitter.should_receive(:search_oauth_connect).with(:get, @uris[:basic], {:to => @to}).and_return(@response)
    @twitter.search(:to => @to)
  end
  
  it "should bless the Array returned from Twitter for :to case" do
    @twitter.should_receive(:bless_models).with(@statuses).and_return(@statuses)
    @twitter.search(:to => @to)
  end
  
  it "should create expected HTTP GET request using :from" do
    @twitter.should_receive(:search_oauth_connect).with(:get, @uris[:basic], {:from => @from}).and_return(@response)
    @twitter.search(:from => @from)
  end
  
  it "should bless the Array returned from Twitter for :to case" do
    @twitter.should_receive(:bless_models).with(@statuses).and_return(@statuses)
    @twitter.search(:from => @from)
  end
  
  it "should create expected HTTP GET request using :keywords" do
    @twitter.should_receive(:search_oauth_connect).with(:get, @uris[:basic], {:keywords => @keywords}).and_return(@response)
    @twitter.search(:keywords => @keywords)
  end
  
  it "should bless the Array returned from Twitter for :keywords case" do
    @twitter.should_receive(:bless_models).with(@statuses).and_return(@statuses)
    @twitter.search(:keywords => @keywords)
  end
  
  it "should accept paging option" do
    lambda {
      @twitter.search(:keywords => @keywords, :page => @page)
    }.should_not raise_error(Exception)
  end

  it "should generate expected GET HTTP request for paging case" do
    @twitter.should_receive(:search_oauth_connect).with(:get, @uris[:basic], {:page => @page}).and_return(@response)
    @twitter.search(:page => @page)
  end

  it "should bless models for paging case" do
    @twitter.should_receive(:bless_models).with(@statuses).and_return(@statuses)
    @twitter.search(:page => @page)
  end
  
  after(:each) do
    nilize(@twitter, @uris, @request, @response, @connection, @statuses)
  end
end
