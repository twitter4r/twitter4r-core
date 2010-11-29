# in your application code
require 'twitter'

module MyAppNamespace::Twitter4RTimeoutMixin
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      # assumes you already depend on ActiveSupport, 
      # but you can mimick with alias_method and more cruft code
      alias_method_chain :rest_consumer, :timeout
      alias_method_chain :search_consumer, :timeout
    end

    module InstanceMethods
      def rest_consumer_with_timeout
        rest_consumer_without_timeout
        config = self.class.config
        connection = @rest_consumer.http
        connection.read_timeout = config.timeout
      end

      def search_consumer_with_timeout
        rest_consumer_without_timeout
        config = self.class.config
        connection = @search_consumer.http
        connection.read_timeout = config.timeout
      end
    end
  end
end

class Twitter::Client
  include(MyAppNamespace::Twitter4RTimeoutMixin)
end
