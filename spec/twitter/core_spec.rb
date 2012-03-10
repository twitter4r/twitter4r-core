require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe "Twitter::ClassUtilMixin mixed-in class" do
  before(:each) do
    class TestClass
      include Twitter::ClassUtilMixin
      attr_accessor :var1, :var2, :var3
    end
    @init_hash = { :var1 => 'val1', :var2 => 'val2', :var3 => 'val3' }
  end

  it "should have Twitter::ClassUtilMixin as an included module" do
    TestClass.included_modules.member?(Twitter::ClassUtilMixin).should be(true)
  end

  it "should set attributes passed in the hash to TestClass.new" do
    test = TestClass.new(@init_hash)
    @init_hash.each do |key, val|
      test.send(key).should eql(val)
    end
  end

  it "should not set attributes passed in the hash that are not attributes in TestClass.new" do
    test = nil
    lambda { test = TestClass.new(@init_hash.merge(:var4 => 'val4')) }.should_not raise_error
    test.respond_to?(:var4).should be(false)
  end
end

describe Twitter::RESTError do
  describe "#to_s" do
    before(:each) do
      @hash = { :code => 200, :message => 'OK', :uri => 'http://test.host/bla' }
      @error = Twitter::RESTError.new(@hash)
      @expected_message = "HTTP #{@hash[:code]}: #{@hash[:message]} at #{@hash[:uri]}"
    end

    it "should return @expected_message" do
      @error.to_s.should eql(@expected_message)
    end
  end

  describe ".register" do
    before(:each) do
      @status_code = '999'
      class MyCustomError < Twitter::RESTError; register('999'); end
    end

    it "should register a new RESTError subclass with a status code" do
      described_class.registry[@status_code].should eql(MyCustomError)
    end
  end
end

describe "Twitter::Status#eql?" do
  before(:each) do
    @id = 34329594003
    @attr_hash = { :text => 'Status', :id => @id,
                   :user => { :name => 'Tess',
                              :description => "Unfortunate D'Urberville",
                              :location => 'Dorset',
                              :url => nil,
                              :id => 34320304,
                              :screen_name => 'maiden_no_more' },
                   :created_at => 'Wed May 02 03:04:54 +0000 2007'}
    @obj = Twitter::Status.new @attr_hash
    @other = Twitter::Status.new @attr_hash
  end

  it "should return true when non-transient object attributes are eql?" do
    @obj.should eql(@other)
  end

  it "should return false when not all non-transient object attributes are eql?" do
    @other.created_at = Time.now.to_s
    @obj.should_not eql(@other)
  end

  it "should return true when comparing same object to itself" do
    @obj.should eql(@obj)
    @other.should eql(@other)
  end
end

describe "Twitter::User#eql?" do
  before(:each) do
    @attr_hash = { :name => 'Elizabeth Jane Newson-Henshard',
                   :description => "Wronged 'Daughter'",
                   :location => 'Casterbridge',
                   :url => nil,
                   :id => 6748302,
                   :screen_name => 'mayors_daughter_or_was_she?' }
    @obj = Twitter::User.new @attr_hash
    @other = Twitter::User.new @attr_hash
  end

  it "should return true when non-transient object attributes are eql?" do
    @obj.should eql(@other)
  end

  it "should return false when not all non-transient object attributes are eql?" do
    @other.id = 1
    @obj.should_not eql(@other)
    @obj.eql?(@other).should be(false)
  end

  it "should return true when comparing same object to itself" do
    @obj.should eql(@obj)
    @other.should eql(@other)
  end
end

describe "Twitter::ClassUtilMixin#require_block" do
  before(:each) do
    class TestClass
      include Twitter::ClassUtilMixin
    end
    @test_subject = TestClass.new
  end

  it "should respond to :require_block" do
    @test_subject.should respond_to(:require_block)
  end

  it "should raise ArgumentError when block not given" do
    lambda {
      @test_subject.send(:require_block, false)
    }.should raise_error(ArgumentError)
  end

  it "should not raise ArgumentError when block is given" do
    lambda {
      @test_subject.send(:require_block, true)
    }.should_not raise_error(ArgumentError)
  end

  after(:each) do
    @test_subject = nil
  end
end

shared_examples_for "REST error returned" do
  before(:each) do
    @twitter = client_context
    @connection = mas_net_http(mas_net_http_response(error_response_code))
  end

  it "should raise relevant RuntimeError subclass" do
    lambda {
      @twitter.account_info
    }.should raise_error(described_class)
  end
end

describe Twitter::NotModifiedError do
  def error_response_code; :not_modified; end
  it_should_behave_like "REST error returned"
end

describe Twitter::RateLimitError do
  def error_response_code; :bad_request; end
  it_should_behave_like "REST error returned"
end

describe Twitter::UnauthorizedError do
  def error_response_code; :not_authorized; end
  it_should_behave_like "REST error returned"
end

describe Twitter::ForbiddenError do
  def error_response_code; :forbidden; end
  it_should_behave_like "REST error returned"
end

describe Twitter::NotFoundError do
  def error_response_code; :file_not_found; end
  it_should_behave_like "REST error returned"
end

describe Twitter::NotAcceptableError do
  def error_response_code; :not_acceptable; end
  it_should_behave_like "REST error returned"
end

describe Twitter::SearchRateLimitError do
  def error_response_code; :search_rate_limit; end
  it_should_behave_like "REST error returned"
end

describe Twitter::InternalServerError do
  def error_response_code; :server_error; end
  it_should_behave_like "REST error returned"
end

describe Twitter::BadGatewayError do
  def error_response_code; :bad_gateway; end
  it_should_behave_like "REST error returned"
end

describe Twitter::ServiceUnavailableError do
  def error_response_code; :service_unavailable; end
  it_should_behave_like "REST error returned"
end

describe Twitter::MediaPart do
  before(:each) do
    @text_content = "My awesome tweet here!"
    @image_content = "(FC@JOCWEOFHEWRGHWEOVAVOCNWDQ"
    @base64_content = Base64.encode64(@image_content)
    @text_content_type = "text/plain; charset=utf-8"
    @image_content_type = "application/octet-stream"
    @image_part = Twitter::MediaPart.new(
      :name => "media[]",
      :filename => "image.png",
      :content_type => @image_content_type,
      :body => @image_content)
    @text_part = Twitter::MediaPart.new(
      :name => "status",
      :content_type => @text_content_type,
      :body => @text_content)
    @text_output = %{\r\nContent-Disposition: form-data; name="status"\r\nContent-Type: #{@text_content_type}\r\n\r\n#{@text_content}\r\n}
    @image_output = %{\r\nContent-Disposition: form-data; name="media[]"; filename="image.png"\r\nContent-Type: #{@image_content_type}\r\nContent-Transfer-Encoding: Base64\r\n\r\n#{@base64_content}\r\n}
  end

  it "should generate body part string per multipart format" do
    @text_part.to_s.should === @text_output
    @image_part.to_s.should === @image_output
  end
end

describe Twitter::MultiPartBody do
  before(:each) do
    @status_type = "text/plain"
    @status_text = "Can't wait for my Ninja Blocks to arrive!;)"
    @status_part = Twitter::MediaPart.new(
      :name => "status",
      :content_type => @status_type,
      :body => @status_text)
    @image_part = Twitter::MediaPart.new(
      :name => "media[]",
      :body => "----BODY-----",
      :content_type => "image/png")
    @digest = "34922jgfejfwef"
    @boundary = @digest
    Digest::SHA1.stub(:hexdigest).and_return(@digest) # ignore the fact it isn't a hexdigest
    @multipart = Twitter::MultiPartBody.new(@image_part, @status_part)
    @expected = %{--#{@boundary}#{@image_part.to_s}--#{@boundary}#{@status_part.to_s}--#{@boundary}--}
  end

  it "shold generate the multipart format expected by HTTP specs" do
    @multipart.to_s.should eql(@expected)
  end
end
