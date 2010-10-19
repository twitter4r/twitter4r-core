$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'rspec'

def require_project_file(file)
  require(File.join(File.dirname(__FILE__), '..', 'lib', file))  
end

require_project_file('twitter')
require_project_file('twitter/console')
require_project_file('twitter/extras')

# Add helper methods here if relevant to multiple _spec.rb files

# Spec helper that sets attribute <tt>att</tt> for given objects <tt>obj</tt> 
# and <tt>other</tt> to given <tt>value</tt>.
def equalizer(obj, other, att, value)
  setter = "#{att}="
  obj.send(setter, value)
  other.send(setter, value)
end

# Spec helper that nil-izes objects passed in
def nilize(*objects)
  objects.each {|obj| obj = nil }
end

# Returns default <tt>client</tt> context object
def client_context(file = 'config/twitter.yml')
  Twitter::Client.from_config(file)
end

# Spec helper that returns a mocked <tt>Twitter::Config</tt> object
# with stubbed attributes and <tt>attrs</tt> for overriding attribute 
# values.
def stubbed_twitter_config(config, attrs = {})
  defaults = Twitter::Client.class_eval("@@defaults")
  opts =  defaults.merge(attrs)
  opts.keys.each do |key|
    config.stub!(key).and_return(opts[key])
  end
  config
end

def mas_twitter_config(attrs = {})
  config = mock(Twitter::Config)
  stubbed_twitter_config(config, attrs)
end

def stubbed_twitter_status(status, attrs = {})
  opts = {
    :id => 23492343,
  }.merge(attrs)
  status.stub!(:id).and_return(opts[:id])
  status.stub!(:to_i).and_return(opts[:id])
  (opts.keys - [:id]).each do |att|
    status.stub!(att).and_return(opts[att])
  end
  status.stub!(:bless).and_return(nil)
  status
end

def mas_twitter_status(attrs = {})
  status = mock(Twitter::Status)
  stubbed_twitter_status(status, attrs)
end

# Spec helper that returns the project root directory as absolute path string
def project_root_dir
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

# Spec helper that returns stubbed <tt>Net::HTTP</tt> object 
# with given <tt>response</tt> and <tt>obj_stubs</tt>.
# The <tt>host</tt> and <tt>port</tt> are used to initialize 
# the Net::HTTP object.
def stubbed_net_http(response, obj_stubs = {}, host = 'twitter.com', port = 80)
  http = Net::HTTP.new(host, port)
  Net::HTTP.stub!(:new).and_return(http)
  http.stub!(:request).and_return(response)
  http
end

# Spec helper that returns a mocked <tt>Net::HTTP</tt> object and 
# stubs out the <tt>request</tt> method to return the given 
# <tt>response</tt>
def mas_net_http(response, obj_stubs = {})
  access_token = mock(OAuth::AccessToken, obj_stubs)
  OAuth::AccessToken.stub!(:new).and_return(access_token)
  access_token.stub!(:request).and_return(response)
  obj_stubs.each do |method, value|
    access_token.stub!(method).and_return(value)
  end
  [:get, :post, :put, :delete].each do |method|
    access_token.stub!(method).and_return(response)
  end
  access_token.stub!(:body).and_return("")
  access_token
end

# Spec helper that returns a mocked <tt>Net::HTTP::Get</tt> object and 
# stubs relevant class methods and given <tt>obj_stubs</tt> 
# for endo-specing
def mas_net_http_get(obj_stubs = {})
  mas_net_http(nil, obj_stubs)
end

# Spec helper that returns a mocked <tt>Net::HTTP::Post</tt> object and 
# stubs relevant class methods and given <tt>obj_stubs</tt> 
# for endo-specing
def mas_net_http_post(obj_stubs = {})
  mas_net_http(nil, obj_stubs)
end

# Spec helper that returns a mocked <tt>Net::HTTPResponse</tt> object and 
# stubs given <tt>obj_stubs</tt> for endo-specing.
# 
def mas_net_http_response(status = :success, 
                          body = '{}', 
                          obj_stubs = {})
  response = RSpec::Mocks::Mock.new(Net::HTTPResponse)
  response.stub!(:body).and_return(body)
  case status
  when :success || 200
    _create_http_response(response, "200", "OK")
  when :created || 201
    _create_http_response(response, "201", "Created")
  when :redirect || 301
    _create_http_response(response, "301", "Redirect")
  when :not_modified || 304
    _create_http_response(response, "304", "Not Modified")
  when :bad_request || 400
    _create_http_response(response, "400", "Bad Request")
  when :not_authorized || 401
    _create_http_response(response, "401", "Not Authorized")
  when :forbidden || 403
    _create_http_response(response, "403", "Forbidden")
  when :file_not_found || 404
    _create_http_response(response, "404", "File Not Found")
  when :not_acceptable || 406
    _create_http_response(response, "406", "Not Acceptable")
  when :search_rate_limit || 420
    _create_http_response(response, "420", "Search Rate Limit")
  when :server_error || 500
    _create_http_response(response, "500", "Server Error")
  when :bad_gateway || 502
    _create_http_response(response, "502", "Bad Gateway")
  when :service_unavailable || 503
    _create_http_response(response, "503", "Service Unavailable")
  end
  response
end

# Local helper method to DRY up code.
def _create_http_response(mock_response, code, message)
  mock_response.stub!(:code).and_return(code)
  mock_response.stub!(:message).and_return(message)
  mock_response.stub!(:is_a?).and_return(true) if ["200", "201"].member?(code)
end
