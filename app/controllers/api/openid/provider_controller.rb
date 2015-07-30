class Api::Openid::ProviderController < Api::Openid::BaseController
  # CSRF-protection must be skipped, because incoming
  # OpenID requests lack an authenticity token
  skip_before_filter :verify_authenticity_token

  # Error handling
  rescue_from OpenID::Server::ProtocolError, with: :render_openid_error

  # Actions other than show require a logged in user
  # before_filter :authenticate_user!, except: [:show]
  before_filter :ensure_valid_checkid_request, except: [:show]
  after_filter :clear_checkid_request, only: [:complete]

  # These methods are used to display information about the request to the user
  helper_method :sreg_request, :ax_fetch_request, :ax_store_request

  layout 'application', only: [:decide]

  # This is the server endpoint which handles all incoming OpenID requests.
  # Associate and CheckAuth requests are answered directly - functionality
  # therefor is provided by the ruby-openid gem. Handling of CheckId requests
  # dependents on the users login state (see handle_checkid_request).
  # Yadis requests return information about this endpoint.
  def show
    clear_checkid_request

    respond_to do |format|
      format.html do
        if openid_request.is_a?(OpenID::Server::CheckIDRequest)
          handle_checkid_request
        elsif openid_request
          handle_non_checkid_request
        else
          render text: t('openid.this_is_openid_not_a_human_ressource')
        end
      end

      format.xrds
    end
  end

  # This action decides how to process the current request and serves as
  # dispatcher and re-entry in case the request could not be processed
  # directly (for instance if the user had to log in first).
  # When the user has already trusted the relying party, the request will
  # be answered based on the users release policy. If the request is immediate
  # (relying party wants no user interaction, used e.g. for ajax requests)
  # the request can only be answered if no further information (like simple
  # registration data) is requested. Otherwise the user will be redirected
  # to the decision page.
  def proceed
    unless params[:user_uid]
      self.render_user_selection_page
      return
    end

    # Retrieve the list of AppInstances accessible by the user for the
    # App currently consuming OpenID
    @user_app_access_list = retrieve_user_access_list_for_app(current_user,current_app)

    # Retrieve the uid of the app being currently launched
    # See AppInstancesController#launch for more info
    current_launch_uid = session.delete(:current_app_instance_launch_uid)

    # Attempt to auto-select an app_instance - either because there is only one
    group = @user_app_access_list.one? ? @user_app_access_list.first : @user_app_access_list.find { |i| i.uid && (i.uid == current_launch_uid) }

    if group
      respond_with_identity(current_user,group)
    elsif @user_app_access_list.any?
      redirect_to decide_api_openid_provider_path(consumer_id)
    else
      redirect_to app_access_unauthorized_path
    end
  end

  # Displays the decision page on which the user can select the AppInstance they
  # wish to access
  def decide
    @meta = { title: 'Select Application', description: 'Select the application you want to login to' }
    @user_app_access_list = retrieve_user_access_list_for_app(current_user,current_app)
  end

  # This action is called by submitting the decision form, the information entered by
  # the user is used to answer the request. If the user decides to always trust the
  # relying party, a new site according to the release policies the will be created.
  def complete
    group = Group.find_by_uid(params[:group_id])

    unless group
      redirect_to app_access_unauthorized_path
      return
    end

    # Prepare and return response
    respond_with_identity(current_user,group)
  end


  #=============================================================
  # Protected
  #=============================================================
  protected

  # Displays a page asking the user to select
  # a system user to login with
  def render_user_selection_page
    @users = User.all

    # Build auth replay url for each user
    @replay = {}

    @users.each do |user|
      @replay[user.id] = {}
      @replay[user.id][:url] = "#{proceed_api_openid_provider_path(user_uid: user.uid)}"

      @replay[user.id][:access] = false
      @replay[user.id][:access_count] = 0
      user.groups.each do |group|
        if (group.app == current_app)
          @replay[user.id][:access] =true
          @replay[user.id][:access_count] += 1
        end
      end
    end

    render template: "shared/auth/select_user_to_login", layout: 'application'
  end


  def add_identity_details(resp,user,group)
    reseller = Reseller.new

    # Prepare Basic Registration data
    sreg_data = {
      'nickname' => user.name,
      'fullname' => "#{user.name} #{user.surname}",
      'email'    => user.email
    }

    # Prepare Exchange Data
    ax_data = {
      # User - Identification
      'type.u_guid'          => 'http://openid.net/schema/person/guid',
      'value.u_guid'         => user.uid,
      'type.u_vguid'         => 'http://openid.maestrano.com/schema/person/vguid',
      'value.u_vguid'        => user.virtual_uid(group),

      # User - Contact Details
      'type.u_fname'         => 'http://openid.net/schema/namePerson/first',
      'value.u_fname'        => user.name,
      'type.u_lname'         => 'http://openid.net/schema/namePerson/last',
      'value.u_lname'        => user.surname,
      'type.u_email'         => 'http://openid.net/schema/contact/internet/email',
      'value.u_email'        => user.email,
      'type.u_vemail'        => 'http://openid.maestrano.com/schema/contact/internet/vemail',
      'value.u_vemail'       => user.virtual_email(group),

      # User - Location
      'type.u_country'       => 'http://openid.net/schema/contact/country/home',
      'value.u_country'      => user.geo_country_code,
      'type.u_city'          => 'http://openid.net/schema/contact/city/home',
      'value.u_city'         => 'Los Angeles',
      'type.u_tz'            => 'http://openid.net/schema/timezone',
      'value.u_tz'           => 'America/Los_Angeles',

      # User - Session
      'type.u_session_key'   => 'http://openid.maestrano.com/schema/session/key',
      'value.u_session_key'  => user.sso_session.to_s,
      'type.u_session_exp'   => 'http://openid.maestrano.com/schema/session/expiration',
      'value.u_session_exp'  => 3.minutes.from_now.utc.iso8601,

      # Group - Identification
      'type.g_guid'          => 'http://openid.maestrano.com/schema/company/guid',
      'value.g_guid'         => group.uid,

      # User - Group Role
      'type.g_u_role'        => 'http://openid.maestrano.com/schema/company/role',
      'value.g_u_role'       => user.role(group),

      # Group - Contact
      'type.g_name'          => 'http://openid.net/schema/company/name',
      'value.g_name'         => group.name,
      'type.g_email'         => 'http://openid.maestrano.com/schema/company/email',
      'value.g_email'        => "#{group.uid}@example.com",

      # Group - Location
      'type.g_country'       => 'http://openid.maestrano.com/schema/company/country',
      'value.g_country'      => 'US',
      'type.g_city'          => 'http://openid.maestrano.com/schema/company/city',
      'value.g_city'         => 'Los Angeles',
      'type.g_tz'            => 'http://openid.maestrano.com/schema/company/timezone',
      'value.g_tz'           => 'America/Los_Angeles',

      # Group - Introduced by reseller?
      'type.g_reseller_id'    => 'http://openid.maestrano.com/schema/company/reseller_id',
      'value.g_reseller_id'   => reseller.uid.to_s,
    }

    # Add reseller metadata
    if session.delete(:reseller_sso)
      ax_data.merge!(
        # Reseller Data
        'type.r_guid'       => 'http://openid.maestrano.com/schema/reseller/guid',
        'value.r_guid'      => reseller.uid.to_s,

        'type.r_name'       => 'http://openid.maestrano.com/schema/reseller/name',
        'value.r_name'      => reseller.name.to_s,

        'type.r_country'    => 'http://openid.maestrano.com/schema/reseller/country',
        'value.r_country'   => reseller.country.to_s,
      )
    end

    # Remove any AX property for which there is a blank value
    # Note: does not handle array values like value.g_country.1
    ax_data.each do |k,v|
      if v.blank?
        ax_property = k.split('.').last
        ax_data.delete("type.#{ax_property}")
        ax_data.delete("value.#{ax_property}")
      end
    end

    # Prepare Response
    resp = add_pape(resp, auth_policies, auth_level, auth_time)
    resp = add_sreg(resp, sreg_data)
    resp = add_ax(resp, ax_data)

    return resp
  end

  # Prepare a complete OpenID response based on the provided
  # User and AppInstance
  def respond_with_identity(user,group)
    resp = checkid_request.answer(true, nil, openid_identifier(user))
    resp = add_identity_details(resp,user,group)
    render_response(resp)
  end

  # Return all the app_instances the user has access
  # to (either because he is the owner or via organization)
  # for a given App
  def retrieve_user_access_list_for_app(user,app)
    user.groups.where(app_id: app.id)
  end

  # Decides how to process an incoming checkid request. If the user is
  # already logged in he will be forwarded to the proceed action. If
  # the user is not logged in and the request is immediate, the request
  # cannot be answered successfully. In case the user is not logged in,
  # the request will be stored and the user is asked to log in.
  def handle_checkid_request
    if allow_verification?
      save_checkid_request
      redirect_to proceed_api_openid_provider_path(consumer_id)
    elsif openid_request.immediate
      render_response(openid_request.answer(false))
    else
      reset_session
      request = save_checkid_request
      session[:previous_url] = proceed_api_openid_provider_path(consumer_id)
      self.render_user_selection_page
    end
  end

  # Stores the current OpenID request.
  # Returns the OpenIdRequest
  def save_checkid_request
    clear_checkid_request
    session[:current_openid_request_params] = openid_params

    request
  end

  # Deletes the old request when a new one comes in.
  def clear_checkid_request
    unless session[:current_openid_request_params].blank?
      session[:current_openid_request_params] = nil
    end
  end

  # Use this as before_filter for every CheckID request based action.
  # Loads the current openid request and cancels if none can be found.
  # The user has to log in, if he has not verified his ownership of
  # the identifier, yet.
  def ensure_valid_checkid_request
    self.openid_request = checkid_request
    if !openid_request.is_a?(OpenID::Server::CheckIDRequest)
      redirect_to root_path, :alert => t('openid.identity_verification_request_invalid')
    elsif !allow_verification?
      flash[:notice] = user_signed_in? && !pape_requirements_met?(auth_time) ?
        t('openid.service_provider_requires_reauthentication_last_login_too_long_ago') :
        t('openid.login_to_verify_identity')
      session[:previous_url] = proceed_api_openid_provider_path
      redirect_to new_user_session_path(ltype:'sso')
    end
  end

  # The user must be logged in, he must be the owner of the claimed identifier
  # and the PAPE requirements must be met if applicable.
  def allow_verification?
    user_signed_in? && correct_identifier? && pape_requirements_met?(auth_time)
  end

  # Is the user allowed to verify the claimed identifier? The user
  # must be logged in, so that we know his identifier or the identifier
  # has to be selected by the server (id_select).
  def correct_identifier?
    (openid_request.identity == openid_identifier(current_user) || openid_request.id_select)
  end

  # Clears the stored request and answers
  def render_response(resp)
    clear_checkid_request
    render_openid_response(resp)
  end

  # Transforms the parameters from the form to valid AX response values
  def transform_ax_data(parameters)
    data = {}
    parameters.each_pair do |key, details|
      if details['value']
        data["type.#{key}"] = details['type']
        data["value.#{key}"] = details['value']
      end
    end
    data
  end

  # Renders the exception message as text output
  def render_openid_error(exception)
    error = case exception
    when OpenID::Server::MalformedTrustRoot then "Malformed trust root '#{exception.to_s}'"
    else exception.to_s
    end
    render :text => "Invalid OpenID request: #{error}", :status => 500
  end

  private

  # The NIST Assurance Level, see:
  # http://openid.net/specs/openid-provider-authentication-policy-extension-1_0-01.html#anchor12
  # Typically:
  # 1 -> no SSL
  # 2 -> SSL
  # 3 -> SSL + Multifactor authentication
  # 4 -> SSL + Hard crypto token
  def auth_level
    2
  end

  def auth_time
    1.minute.ago
  end

  # Return which authentication policies to apply
  # E.g.: OpenID::PAPE::AUTH_MULTI_FACTOR, OpenID::PAPE::AUTH_PHISHING_RESISTANT
  def auth_policies
    []
  end
end
