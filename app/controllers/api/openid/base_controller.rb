require 'openid'
require 'openid/consumer/discovery'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'

class Api::Openid::BaseController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_valid_consumer!
  
  helper_method :extract_host, :extract_login_from_identifier, :checkid_request,
    :openid_identifier, :openid_endpoint_url, :consumer_id, :current_user

  protected
  
  def current_app
    App.find_by_uid(consumer_id)
  end
  
  # Return the id of the service (relaying party - app provider) currently
  # using OpenID authentication
  def consumer_id
    params[:provider_id] || params[:id]
  end
  
  def openid_endpoint_url
    api_openid_provider_url(consumer_id)
  end

  # Returns the OpenID identifier for a user
  def openid_identifier(user,opts = {})
    api_openid_provider_user_url(opts.merge(provider_id: consumer_id, id: user.uid))
  end

  # Extracts the hostname from the given url, which is used to
  # display the name of the requesting website to the user
  def extract_host(u)
    u[/(?:https?:\/\/)?(.+?)(\/|$)/, 1]
  end

  def extract_login_from_identifier(openid_url)
    openid_url.gsub(/^https?:\/\/.*\//, '')
  end

  def checkid_request
    unless @checkid_request
      req = openid_server.decode_request(current_openid_request_params) if current_openid_request_params
      @checkid_request = req.is_a?(OpenID::Server::CheckIDRequest) ? req : false
    end
    @checkid_request
  end

  def current_openid_request_params
    @current_openid_request ||= session[:current_openid_request_params]
  end

  # Store location in session so that Devise can catchup
  # after sign_in (only if user logged in)
  # ---
  # Note: this controller does not inherit from ApplicationController
  # (which implements a store location callback). This is why we
  # have to re-implement it here separately
  def store_location
    unless current_user
      session[:previous_url] = request.original_url
    end
  end
  
  # Check that the consumer (app provider) exists
  def check_valid_consumer!
    unless current_app
      sp = extract_host(request.referrer) rescue nil
      redirect_to app_access_unauthorized_path
      return false
    end
    true
  end
  
  # Method gets overriden to include ltype:'sso'
  # in the redirection url (login page content changes
  # based on whether it is a regular login or a sso one)
  # --
  # Note: just in case we check that the user email is NOT
  # equal to the support one because this email is by admins
  # to support to login to customer applications.
  # A potential attack could consist in trying to signup with
  # the support email to gain access to applications that admins
  # have already accessed (once an email is in an app then the user
  # holding that email has access to it)
  # def authenticate_user!
  #   unless user_signed_in? && current_user.email != APP_CONFIG['support_email']
  #     store_location
  #     redirect_to(new_user_session_path(ltype:'sso'))
  #   end
  # end
  
  # OpenID store reader, used inside this module
  # to procide access to the storage mechanism
  def openid_store
    @openid_store ||= ActiveRecordOpenidStore::ActiveRecordStore.new
  end

  # OpenID server reader, use this to access the server
  # functionality from inside your server controller
  def openid_server
    @openid_server ||= OpenID::Server::Server.new(openid_store, openid_endpoint_url)
  end

  # OpenID parameter reader, use this to access only OpenID
  # request parameters from inside your server controller
  def openid_params
    @openid_params ||= params.clone.delete_if { |k,v| k.index('openid.') != 0 }
  end

  # OpenID request accessor
  def openid_request
    @openid_request ||= openid_server.decode_request(openid_params)
  end

  # Sets the current OpenID request and resets all dependent requests
  def openid_request=(req)
    @openid_request, @sreg_request, @ax_fetch_request, @ax_store_request = req, nil, nil, nil
  end

  # SReg request reader
  def sreg_request
    @sreg_request ||= OpenID::SReg::Request.from_openid_request(openid_request)
  end

  # Attribute Exchange fetch request reader
  def ax_fetch_request
    @ax_fetch_request ||= OpenID::AX::FetchRequest.from_openid_request(openid_request)
  end

  # Attribute Exchange store request reader
  def ax_store_request
    @ax_store_request ||= OpenID::AX::StoreRequest.from_openid_request(openid_request)
  end

  # PAPE request reader
  def pape_request
    @pape_request ||= OpenID::PAPE::Request.from_openid_request(openid_request)
  end

  # Adds SReg data (Hash) to an OpenID response.
  def add_sreg(resp, data)
    if sreg_request
      sreg_resp = OpenID::SReg::Response.extract_response(sreg_request, data)
      resp.add_extension(sreg_resp)
    end
    resp
  end

  # Adds Attribute Exchange data (Hash) to an OpenID response. See:
  # http://rakuto.blogspot.com/2008/03/ruby-fetch-and-store-some-attributes.html
  def add_ax(resp, data)
    ax_resp = OpenID::AX::FetchResponse.new
    ax_args = data.reverse_merge('mode' => 'fetch_response')
    ax_resp.parse_extension_args(ax_args)
    resp.add_extension(ax_resp)
    resp
  end

  # Adds PAPE information for your server to an OpenID response.
  def add_pape(resp, policies = [], nist_auth_level = 0, auth_time = nil)
    if papereq = OpenID::PAPE::Request.from_openid_request(openid_request)
      paperesp = OpenID::PAPE::Response.new
      policies.each { |p| paperesp.add_policy_uri(p) }
      paperesp.nist_auth_level = nist_auth_level
      paperesp.auth_time = auth_time.utc.iso8601
      resp.add_extension(paperesp)
    end
    resp
  end

  # Answers check auth and associate requests.
  def handle_non_checkid_request
    resp = openid_server.handle_request(openid_request)
    render_openid_response(resp)
  end

  # Renders the final response output
  # Note: if the OpenID response is too big then the response
  # is rendered as a form that automatically submits itself via JavaScript
  def render_openid_response(resp)
    signed_response = openid_server.signatory.sign(resp) if resp.needs_signing
    web_response = openid_server.encode_response(resp)
    case web_response.code
    when OpenID::Server::HTTP_OK then render(text: auto_submitted_form(web_response.body), status: 200)
    when OpenID::Server::HTTP_REDIRECT then redirect_to(web_response.headers['location'])
    else render(text: web_response.body, status: 400)
    end
  end
  
  # Insert the OpenID response content into a page autosubmitting the OpenID form
  def auto_submitted_form(body)
    html = <<EOS
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
</head>
<body onload="document.forms[0].submit();" style="visibility:hidden;">
#{body}
</body>
</html>
EOS
    html
  end

  # If the request contains a max_auth_age, the last authentication date
  # must meet this requirement, otherwise the user has to reauthenticate:
  # http://openid.net/specs/openid-provider-authentication-policy-extension-1_0-02.html#anchor9
  def pape_requirements_met?(auth_time)
    return true unless pape_request && pape_request.max_auth_age
    (Time.now - auth_time).to_i <= pape_request.max_auth_age
  end
  
end