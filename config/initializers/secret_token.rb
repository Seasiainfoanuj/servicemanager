# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
ServiceManager::Application.config.secret_key_base = '205e59660b1772c22d2ec24963da820edef05077220933ad7f8e11c476c42729922d5ca61c29c1d30ea1602a4e91ef21ed1836cc0ec9c6fb5bc9f125e9480faf'
