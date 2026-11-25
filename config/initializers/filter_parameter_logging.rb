# Be sure to restart your server when you modify this file.

# Filter sensitive request parameters from application logs.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key,
  :crypt, :salt, :certificate, :otp, :ssn,
  :cvv, :cvc
]

# Prevent temporary signed storage URLs from appearing in logs.
# This does not modify the actual redirect response sent to the browser.
Rails.application.config.filter_redirect += [
  "X-Amz-Signature=",
  "X-Amz-Credential=",
  ".storage.supabase.co/"
]
