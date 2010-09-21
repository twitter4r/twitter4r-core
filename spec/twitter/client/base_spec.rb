require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

shared_examples_for "consumer initialization with timeout" do
  before(:each) do
    @old_timeout = nil
    Twitter::Client.configure do |conf|
      @old_timeout = conf.timeout
      conf.timeout = @timeout
    end
    @client = client_context
  end

  it "should set timeout on underlying HTTP object" do
    consumer = get_consumer
    http = consumer.http
    http.read_timeout.should == timeout
  end

  after(:each) do
    Twitter::Client.configure do |conf|
      conf.timeout = @old_timeout
    end
  end
end

describe "Twitter::Client" do
  before(:each) do
    @init_hash = { :login => 'user', :password => 'pass' }
  end

  it ".new should accept login and password as initializer hash keys and set the values to instance values" do
    client = nil
    lambda do
      client = Twitter::Client.new(@init_hash)
    end.should_not raise_error
    client.send(:login).should eql(@init_hash[:login])
  end  
end

describe Twitter::Client, "#inspect" do
  before(:each) do
    @client = Twitter::Client.new(:login => "NippleEquality", :password => "3rdnipple")
  end

  it "should block out password attribute values" do
    @client.inspect.should_not match(/@password="3rdnipple"/)
  end
end

describe Twitter::Client, "#http_header" do
  before(:each) do
    @user_agent = 'myapp'
    @application_name = @user_agent
    @application_version = '1.2.3'
    @application_url = 'http://myapp.url'
    Twitter::Client.configure do |conf|
      conf.user_agent = @user_agent
      conf.application_name = @application_name
      conf.application_version = @application_version
      conf.application_url = @application_url
    end
    @expected_headers = {
      'Accept' => 'text/x-json',
      'X-Twitter-Client' => @application_name,
      'X-Twitter-Client-Version' => @application_version,
      'X-Twitter-Client-URL' => @application_url,
      'User-Agent' => "Twitter4R v#{Twitter::Version.to_version} [#{@user_agent}]",
    }
    @twitter = client_context
    # reset @@http_header class variable in Twitter::Client class
    Twitter::Client.class_eval("@@http_header = nil")
  end
  
  it "should always return expected HTTP headers" do
    headers = @twitter.send(:http_header)
    headers.should === @expected_headers
  end
  
  it "should cache HTTP headers Hash in class variable after first invocation" do
    cache = Twitter::Client.class_eval("@@http_header")
    cache.should be_nil
    @twitter.send(:http_header)
    cache = Twitter::Client.class_eval("@@http_header")
    cache.should_not be_nil
    cache.should === @expected_headers
  end
  
  after(:each) do
    nilize(@user_agent, @application_name, @application_version, @application_url, @twitter, @expected_headers)
  end
end

describe Twitter::Client, "#bless_model" do
  before(:each) do
    @twitter = client_context
    @model = Twitter::User.new
  end
  
  it "should recieve #client= message on given model to self" do
  	@model.should_receive(:client=).with(@twitter)
    model = @twitter.send(:bless_model, @model)
  end
  
  it "should set client attribute on given model to self" do
    model = @twitter.send(:bless_model, @model)
    model.client.should eql(@twitter)
  end

  # if model is nil, it doesn't not necessarily signify an exceptional case for this method's usage.
  it "should return nil when receiving nil and not raise any exceptions" do
    model = @twitter.send(:bless_model, nil)
    model.should be_nil
  end
  
  # needed to alert developer that the model needs to respond to #client= messages appropriately.
  it "should raise an error if passing in a non-nil object that doesn't not respond to the :client= message" do
    lambda {
      @twitter.send(:bless_model, Object.new)      
    }.should raise_error(NoMethodError)
  end
  
  after(:each) do
    nilize(@twitter)
  end
end

describe Twitter::Client, "#bless_models" do
  before(:each) do
    @twitter = client_context
    @models = [
    	Twitter::Status.new(:text => 'message #1'),
    	Twitter::Status.new(:text => 'message #2'),
    ]
  end

  it "should set client attributes for each model in given Array to self" do
    models = @twitter.send(:bless_models, @models)
    models.each {|model| model.client.should eql(@twitter) }
  end
  
  it "should set client attribute for singular model given to self" do
    model = @twitter.send(:bless_models, @models[0])
    model.client.should eql(@twitter)
  end
  
  it "should delegate to bless_model for singular model case" do
    model = @models[0]
    @twitter.should_receive(:bless_model).with(model).and_return(model)
    @twitter.send(:bless_models, model)
  end
  
  it "should return nil when receiving nil and not raise any exceptions" do
    lambda {
      value = @twitter.send(:bless_models, nil)
      value.should be_nil
    }.should_not raise_error
  end
  
  after(:each) do
    nilize(@twitter, @models)
  end
end

shared_examples_for "consumer token overrides" do
  before(:each) do
    @config_key = "234ufmewroi23o43SFsf"
    @config_secret = "kfgIYFOasdfsfg236GSka"
    @key_override = "#{@config_key}-1234"
    @secret_override = "#{@config_secret}-1234"
    Twitter::Client.configure do |conf|
      conf.oauth_consumer_token = @config_key
      conf.oauth_consumer_secret = @config_secret
    end
    @overridded_client = Twitter::Client.new(:oauth_consumer => { :key => @key_override, :secret => @secret_override })
    @plain_client = Twitter::Client.new
  end

  it "should be set to key/secret pair passed into constructor when passed in and configuration object already has key/secret set" do
    consumer = get_consumer(@overridded_client)
    consumer.instance_eval("@key").should eql(@key_override)
    consumer.instance_eval("@secret").should eql(@secret_override)
  end

  it "should be set to key/secret pair set in configuration object when none passed into constructor" do
    consumer = get_consumer(@plain_client)
    consumer.instance_eval("@key").should eql(@config_key)
    consumer.instance_eval("@secret").should eql(@config_secret)
  end

  after(:each) do
    Twitter::Client.configure do |conf|
      conf.oauth_consumer_token = nil
      conf.oauth_consumer_secret = nil
    end
  end
end

describe Twitter::Client, "rest consumer token" do
  it_should_behave_like "consumer token overrides"

  def get_consumer(client)
    client.send(:rest_consumer)
  end
end

describe Twitter::Client, "search consumer token" do
  it_should_behave_like "consumer token overrides"

  def get_consumer(client)
    client.send(:search_consumer)
  end
end

describe Twitter::Client, "#construct_proxy_url" do
  before(:each) do
    @host = "localhost"
    @port = "8080"
    @user = "user"
    @pass = "pass123"
    @client = client_context
  end

  def configure_host_and_port
    Twitter::Client.configure do |conf|
      conf.proxy_host = @host
      conf.proxy_port = @port
    end
  end

  def configure_user_and_password
    Twitter::Client.configure do |conf|
      conf.proxy_user = @user
      conf.proxy_pass = @pass
    end
  end

  it "should return the full proxy URL when proxy host and port given" do
    configure_host_and_port
    url = "http://#{@host}:#{@port}"
    @client.send(:construct_proxy_url).should eql(url)
  end

  it "should return the full proxy URL when proxy host, port, username and password given" do
    configure_host_and_port
    configure_user_and_password
    url = "http://#{@user}:#{@pass}@#{@host}:#{@port}"
    @client.send(:construct_proxy_url).should eql(url)
  end

  it "should return nil when no proxy host is given" do
    @client.send(:construct_proxy_url).should eql(nil)
  end

  after(:each) do
    Twitter::Client.configure do |conf|
      conf.proxy_user = nil
      conf.proxy_pass = nil
      conf.proxy_host = nil
      conf.proxy_port = nil
    end
  end
end

describe Twitter::Client, "#rest_consumer" do
  it_should_behave_like "consumer initialization with timeout"
  before(:each) do
    @timeout = 49
  end

  def timeout
    @timeout
  end

  def get_consumer
    @client.send(:rest_consumer)
  end
end

describe Twitter::Client, "#search_consumer" do
  it_should_behave_like "consumer initialization with timeout"
  before(:each) do
    @timeout = 96
  end

  def timeout
    @timeout
  end

  def get_consumer
    @client.send(:search_consumer)
  end
end
