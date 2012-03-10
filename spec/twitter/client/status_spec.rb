require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Twitter::Client, "#status" do
  before(:each) do
    @twitter = client_context
    @message = 'This is my unique message'
    @uris = Twitter::Client.class_eval("@@STATUS_URIS")
    @options = {:id => 666666}
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, '{}')
    @connection = mas_net_http(@response)
    @float = 43.3434
    @status = Twitter::Status.new(:id => 2349343)
    @reply_to_status_id = 3495293
    @source = Twitter::Client.class_eval("@@defaults[:source]")
    @image_data = "----IMAGEDATA######"
    @image_part = Twitter::MediaPart.new(
      :name => "media[]", :filename => "image.png",
      :content_type => "application/octet-stream",
      :body => @image_data)
    @status_part = Twitter::MediaPart.new(
      :name => "status",
      :content_type => "text/plain",
      :body => @message)
  end

  it "should return nil if nil is passed as value argument for :get case" do
    status = @twitter.status(:get, nil)
    status.should be_nil
  end

  it "should not call @twitter#http_connect when passing nil for value argument in :get case" do
    @twitter.should_not_receive(:http_connect)
    @twitter.status(:get, nil)
  end

  it "should create expected HTTP GET request for :get case" do
    @twitter.should_receive(:rest_oauth_connect).with(:get, @uris[:get], @options).and_return(@response)
    @twitter.status(:get, @options[:id])
  end

  it "should invoke @twitter#rest_oauth_connect with given parameters equivalent to {:id => value.to_i} for :get case" do
    # Float case
    @twitter.should_receive(:rest_oauth_connect).with(:get, @uris[:get], {:id => @float.to_i}).and_return(@response)
    @twitter.status(:get, @float)

    # Twitter::Status object case
    @twitter.should_receive(:rest_oauth_connect).with(:get, @uris[:get], {:id => @status.to_i}).and_return(@response)
    @twitter.status(:get, @status)
  end

  it "should create expected HTTP POST request for :post case" do
    @twitter.should_receive(:rest_oauth_connect).with(:post, @uris[:post], :status => @message, :source => @source).and_return(@response)
    @twitter.status(:post, @message)
  end

  it "should create expected HTTP POST request for :post case when passing Hash with lat/long instead of String" do
    @twitter.should_receive(:rest_oauth_connect).with(:post, @uris[:post], :lat => 0, :long => 0, :status => @message, :source => @source).and_return(@response)
    @twitter.status(:post, :status => @message, :lat => 0, :long => 0)
  end

  it "should create expected HTTP POST request for :post case when passing Hash with place_id instead of String" do
    @twitter.should_receive(:rest_oauth_connect).with(:post, @uris[:post], :place_id => 1234, :status => @message, :source => @source).and_return(@response)
    @twitter.status(:post, :status => @message, :place_id => 1234)
  end

  it "should create expected HTTP POST request for :post case when passing Hash with media entries" do
    @twitter.should_receive(:media_oauth_connect).
      with(:post, @uris[:post_multipart], hash_including(:parts)).
      and_return(@response)
    @twitter.status(:post,
      :media => {
        :filename => "image.png",
        :content_type => "application/octet-stream",
        :body => @image_data},
      :status => @message
      )
  end

  it "should return nil if nil is passed as value argument for :post case" do
    status = @twitter.status(:post, nil)
    status.should be_nil
  end

  it "should return nil if no :status key-value given in the value argument for :reply case" do
    status = @twitter.status(:reply, {})
    status.should be_nil
  end

  it "should return nil if nil is passed as value argument for :reply case" do
    status = @twitter.status(:reply, nil)
    status.should be_nil
  end

  it "should create expected HTTP POST request for :reply case" do
    @twitter.should_receive(:rest_oauth_connect).with(:post, @uris[:reply], :status => @message, :source => @source, :in_reply_to_status_id => @reply_to_status_id).and_return(@response)
    @twitter.status(:reply, :status => @message, :in_reply_to_status_id => @reply_to_status_id)
  end

  it "should return nil if nil is passed as value argument for :delete case" do
    status = @twitter.status(:delete, nil)
    status.should be_nil
  end

  it "should create expected HTTP DELETE request for :delete case" do
    @twitter.should_receive(:rest_oauth_connect).with(:delete, @uris[:delete], @options).and_return(@response)
    @twitter.status(:delete, @options[:id])
  end

  it "should invoke @twitter#rest_oauth_connect with given parameters equivalent to {:id => value.to_i} for :delete case" do
    # Float case
    @twitter.should_receive(:rest_oauth_connect).with(:delete, @uris[:delete], {:id => @float.to_i}).and_return(@response)
    @twitter.status(:delete, @float)

    # Twitter::Status object case
    @twitter.should_receive(:rest_oauth_connect).with(:delete, @uris[:delete], {:id => @status.to_i}).and_return(@response)
    @twitter.status(:delete, @status)
  end

  it "should raise an ArgumentError when given an invalid status action" do
    lambda {
      @twitter.status(:crap, nil)
    }.should raise_error(ArgumentError)
  end

  after(:each) do
    nilize(@twitter)
  end
end
