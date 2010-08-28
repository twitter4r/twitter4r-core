require('twitter')
require('twitter/console')

## NOTE: OAUTH authentication:

# For Twitter4R v 0.5.0 and above...
# Supply the OAuth access key and secret respective to the constructor
# to use the client in authenticated mode for subsequent calls.
client = Twitter::Client.new(access_key, access_secret)
# If you only want to use the Twitter4R client to ensure the keys are 
# still authorized you can validate the credentials your applicaiton 
# has for the user this way:
client = Twitter::Client.new
puts client.autenticate?(access_key, access_secret)

## For Twitter4R v0.4.0 and below...
## OLD: Below is a demonstration of the old username/password scheme.
## Twitter.com completely removes support for this on August 31, 2010.
# Supply the username and password of the user to the constructor to 
# use the client in authenticated mode for subsequent calls.
client = Twitter::Client.new("osxisforlightweights","sn0wl30p@rd_s^cks!")

# If you only want to use the Twitter4R client to ensure the keys are
# still authorized you can validate the credentials your application 
# has for the user this way:
client = Twitter::Client.new
# This will only verify credentials NOT save the username and password 
# for use in subsequent calls.
puts client.authenticate?("osxisforlightweights", "l30p@rd_s^cks!")

