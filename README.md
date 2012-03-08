# Twitter4R

* Project Website - http://twitter4r.rubyforge.org
* Mailing List - http://groups.google.com/group/twitter4r-users
* Issues - http://github.com/twitter4r/twitter4r-core/issues

## Description

Twitter4R provides an object based API to query or update your Twitter account via pure Ruby.  It hides the ugly HTTP/REST code from your code.

## Installation

<code>gem install twitter4r</code>

## Getting Started

Add the <code>twitter4r</code> dependency to your <code>Gemfile</code>:

<pre><code>
gem 'twitter4r', :require => 'twitter'
</code></pre>

Set your OAuth consumer key and token like so:

<pre><code>
Twitter.configure do |config|
  config.oauth_consumer_token = CONSUMER_KEY_HERE
  config.oauth_consumer_secret = CONSUME_SECRET_HERE
end
</code></pre>

To create a client object with access tokens:

<pre><code>
  client = Twitter::Client.new(:oauth_access => {
      :key => ACCESS\_KEY, :secret => ACCESS\_SECRET
    }
  client.status(:post, "Your awesome less than 140 characters tweet goes here!!! #with #hashtag #goodness")
</code></pre>


## Usage Examples

Twitter4R starting with version 0.1.1 and above is organized into seven parts:

* [Configuration API](link:examples/configure_rb.html)
* [Friendship API](link:examples/friendship_rb.html)
* [Messaging API](link:examples/messaging_rb.html)
* [Model API](link:examples/model_rb.html)
* [Status API](link:examples/status_rb.html)
* [Timeline API](link:examples/timeline_rb.html)
* [User API](link:examples/user_rb.html)

## Features

Library supports:

* OAuth support for authentication with the Twitter.com REST and Search APIs
* identi.ca API access
* Customizability of API endpoints such that any Twitter.com compliant API can be accessed (not just Twitter.com and identi.ca's)
* Uses lightweight native JSON under the hood as opposed to heavyweight XML parsing (which is what other Ruby Twitter client libraries use)

Twitter.com REST API coverage includes:

* Status posting and retrieving
* User information
* Profile updates and retrieval
* Favorites add, remove, retrieve
* Direct messaging post, remove, read
* Friendship adding, removing, blocking
* Geolocation embedding inside of statuses and reading from statuses
* Rate limit status access
* Trends retrieval and trend location querying

Twitter.com Search API coverage includes:

* Searching with various options

## Developers

* [Susan Potter](http://SusanPotter.NET) <me at susanpotter dot net>

## Contributors

Code:

* Kaiichi Matsunaga <ma2 at lifemedia dot co dot jp> - proxy code suggestion
* Sergio Santos <> - message paging code suggestion
* Adam Stiles <adam at stilesoft dot com> - URI.encode => CGI.escape fix
* Carl Crawley <cwcrawley at gmail dot com> - Friendship get => post fix
* Christian Johansen <christian at cjohansen dot no> - in_reply_to attributes in Twitter::Status
* Harry Love <harrylove at gmail dot com> - added attributes to Twitter::Status
* Filipe Giusti <filipegiusti at gmail dot com> - fixed users/show issue that Twitter.com changed from under us, also inspired the v0.5.2 bugfix release by submitting great issue example code.
* Seth Cousins <seth.cousins at gmail dot com> - added HTTP timeout option and provided a patch that inspired the OAuth support for Twitter4R
* John McKerrell <@mcknut on twitter> - added geo attribute to Twitter::Message.
* domrout on GitHub - added Tweet Entities.

Design Suggestions:

* Bosco So <rubymeetup at boscoso dot com> - making Twitter::Error a RuntimeError instead of an Exception to prevent irb from crashing out.

## External Dependencies

* Ruby 1.8 (tested with 1.8.6)
* RSpec gem 1.0.0+ (tested with 1.1.3)
* JSON gem 0.4.3+ (tested with versions: 1.1.1 and 1.1.2)
* jcode (for unicode support)
