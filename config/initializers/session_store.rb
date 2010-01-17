# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cofgratx_session',
  :secret      => 'be4495c1b964642cc615561771458d6e8747d3a269142a10ac4ac9651a138968270ac37091f4522001032bafb9ca5255df2a3ffac882987d6bec168f37122989'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
