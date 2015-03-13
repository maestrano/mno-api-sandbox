# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.register "application/vnd.api+json", :json_api
ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime::JSON_API] = -> body { JSON.parse body }

# OpenID Yadis Discovery mime type
Mime::Type.register "application/xrds+xml", :xrds