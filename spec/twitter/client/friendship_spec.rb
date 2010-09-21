require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Twitter::Client, "#friendships" do
  before(:each) do
    @twitter = client_context
    @uris = Twitter::Client.class_eval("@@FRIENDSHIP_URIS")
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    @result = { :id_list => { :ids => [] } }
    JSON.stub!(:parse).and_return(@result)
  end

  it "should create expected HTTP GET request for :incoming case" do
    @twitter.should_receive(:rest_oauth_connect).with(:get, @uris[:incoming]).and_return(@response)
    @twitter.friendships(:incoming)
  end

  it "should create expected HTTP GET request for :outgoing case" do
    @twitter.should_receive(:rest_oauth_connect).with(:get, @uris[:outgoing]).and_return(@response)
    @twitter.friendships(:outgoing)
  end
end

describe Twitter::Client, "#friend" do
  before(:each) do
    @twitter = client_context
    @id = 1234567
    @screen_name = 'dummylogin'
    @friend = Twitter::User.new(:id => @id, :screen_name => @screen_name)
    @uris = Twitter::Client.class_eval("@@FRIEND_URIS")
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    Twitter::User.stub!(:unmarshal).and_return(@friend)
  end

  def create_uri(action, id)
    "#{@uris[action]}/#{id}.json"
  end

  it "should create expected HTTP POST request for :add case using integer user ID" do
    # the integer user ID scenario...
    @twitter.should_receive(:rest_oauth_connect).with(:post, create_uri(:add, @id)).and_return(@response)
    @twitter.friend(:add, @id)
  end

  it "should create expected HTTP POST request for :add case using screen name" do
    # the screen name scenario...
    @twitter.should_receive(:rest_oauth_connect).with(:post, create_uri(:add, @screen_name)).and_return(@response)
    @twitter.friend(:add, @screen_name)
  end

  it "should create expected HTTP GET request for :add case using Twitter::User object" do
    # the Twitter::User object scenario...
    @twitter.should_receive(:rest_oauth_connect).with(:post, create_uri(:add, @friend.to_i)).and_return(@response)
    @twitter.friend(:add, @friend)
  end

  it "should create expected HTTP GET request for :remove case using integer user ID" do
    # the integer user ID scenario...
    @twitter.should_receive(:rest_oauth_connect).with(:post, create_uri(:remove, @id)).and_return(@response)
    @twitter.friend(:remove, @id)
  end

  it "should create expected HTTP GET request for :remove case using screen name" do
    # the screen name scenario...
    @twitter.should_receive(:rest_oauth_connect).with(:post, create_uri(:remove, @screen_name)).and_return(@response)
    @twitter.friend(:remove, @screen_name)
  end

  it "should create expected HTTP GET request for :remove case using Twitter::User object" do
    # the Twitter::User object scenario...
    @twitter.should_receive(:rest_oauth_connect).with(:post, create_uri(:remove, @friend.to_i)).and_return(@response)
    @twitter.friend(:remove, @friend)
  end

  it "should bless user model returned for :add case" do
    @twitter.should_receive(:bless_model).with(@friend)
    @twitter.friend(:add, @friend)
  end

  it "should bless user model returned for :remove case" do
    @twitter.should_receive(:bless_model).with(@friend)
    @twitter.friend(:remove, @friend)
  end

  it "should raise ArgumentError if action given is not valid" do
    lambda {
      @twitter.friend(:crap, @friend)
    }.should raise_error(ArgumentError)
  end

  after(:each) do
    nilize(@twitter, @id, @uris, @response, @connection)
  end
end
