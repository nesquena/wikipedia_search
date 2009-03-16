# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wiki_search_session',
  :secret      => '28d7670c2313c856d953187eea9575b284c84350f0376f41ba0898a1608e92f65a9dea9da81f56cf561d95d314c8c659d1b3fec1d7546cd47099d5e6335c83bc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
