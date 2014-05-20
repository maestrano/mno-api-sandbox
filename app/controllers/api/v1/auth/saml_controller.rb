class Api::V1::Auth::SamlController < SamlIdp::IdpController
  before_filter :store_location, only: [:index]
  before_filter :validate_saml_request, only: [:index]
  before_filter :retrieve_issuer_id, only: [:index]

  # GET /api/v1/auth/saml
  def index
    if !@saml_issuer_id.blank? && @app = App.find_by_api_token(@saml_issuer_id)
      
      # if a user_uid is selected then proceed to SSO response
      # Otherwise ask user to select a system user to login with
      user_uid = (params[:user_uid] || session[:current_user])
      
      if !user_uid.blank? && @current_user = User.find_by_uid(user_uid)
        self.handle_cloud_stack_sso
      else
        self.render_user_selection_page
      end
    else
      render text: "Wrong API token"
    end
  end
  
  # Works with either the user uid, virtual_uid or virtual_email
  # GET /api/v1/auth/saml/usr-xyz?session=f15s34g10f5dh4fg35jh3fg14jhg8
  # GET /api/v1/auth/saml/usr-xyz.cld-g4fd53?session=f15s34g10f5dh4fg35jh3fg14jhg8
  # GET /api/v1/auth/saml/usr-xyz.cld-g4fd53@appmail.maestrano.com?session=f15s34g10f5dh4fg35jh3f
  def show
    # Build response
    response_hash = {
      valid: false,
      recheck: 3.minutes.from_now.utc
    }

    render json: response_hash
  end

  protected
    # Retrieve the issuer id.
    def retrieve_issuer_id
      @saml_issuer_id = @saml_request[/<saml:Issuer\s?.*>(.*)<\/saml:Issuer>/, 1]
      !@saml_issuer_id.blank? && @app = App.find_by_api_token(@saml_issuer_id)
      return true
    end
    
    # Return all groups the user has access to
    # for a given App
    def retrieve_user_access_list_for_app(user,app)
      user.groups.where(app_id: app.id)
    end
    
    # This method is called by the index action
    def handle_cloud_stack_sso
      @group_id = params[:group_id]
      
      # Check that the return url (to consume SSO)
      # matches the app domain
      @user_group_access_list = retrieve_user_access_list_for_app(@current_user,@app)
      
      if @user_group_access_list.one?
        @group = @user_group_access_list.first
        self.render_saml_response_page
      elsif @user_group_access_list.any?
        if !@group_id.blank? && @group = @user_group_access_list.find_by_uid(@group_id)
          self.render_saml_response_page
        else
          self.render_group_selection_page
        end
      else
        self.render_access_denied_page
      end
    end
    
    # Displays a page asking the user to select
    # a system user to login with
    def render_user_selection_page
      @users = User.all
      
      # Remove any group_id param in the url
      saml_url_without_user_id = request.original_url.gsub(/(&user_uid=([^&]*))/,"")
      
      # Build SAML replay url for each user
      @saml_replay_info = {}
      
      @users.each do |user|
        @saml_replay_info[user.id] = {}
        @saml_replay_info[user.id][:url] = "#{saml_url_without_user_id}&user_uid=#{user.uid}"
        
        @saml_replay_info[user.id][:access] = false
        @saml_replay_info[user.id][:access_count] = 0
        user.groups.each do |group|
          if (group.app == @app)
            @saml_replay_info[user.id][:access] =true
            @saml_replay_info[user.id][:access_count] += 1
          end
        end
      end
      
      render template: "api/v1/auth/select_user_to_login", layout: 'application'
    end
    
    # Redirect to service
    # Expect @current_user and @group to be defined
    def render_saml_response_page
      session[:current_user] = nil # reset current user
      @saml_response = self.idp_make_saml_response(@current_user,@group)
      render :template => "saml_idp/idp/saml_post", :layout => false
    end
    
    # Render the 'Access Denied' page
    # This page is displayed when the user does not
    # have access the requested app
    def render_access_denied_page
      # Render fail page
      @meta = {}
      @meta[:title] = "Access Denied"
      @meta[:description] = "You do not have access to this application"
      render :template => "pages/app_access_unauthorized", :layout => 'application', :status => :forbidden
    end
    
    # Render the 'App Selection Confirmation' page
    # This page is rendered when a user tries to access
    # a cloud service without specifying a group_id
    # ---
    # Expect @user_group_access_list to be defined
    def render_group_selection_page
      # Remove any group_id param in the url
      saml_url_without_group_id = request.original_url.gsub(/(&group_id=([^&]*))/,"")
      
      # Build SAML replay url for each group
      @saml_replay_urls = {}
      @user_group_access_list.each do |group|
        @saml_replay_urls[group.id] = "#{saml_url_without_group_id}&group_id=#{group.uid}"
      end
      
      render template: "api/v1/auth/select_group_to_login", layout: 'application'
    end

    # Prepare the assertions that will be shared
    # in the saml response
    def idp_build_user_assertions(user,group)
      hash = {}
      hash[:attributes] = {}

      # Populate the session information
      hash[:name_id] = user.uid
      hash[:attributes][:mno_session] = user.sso_session
      hash[:attributes][:mno_session_recheck] = 3.minutes.from_now.utc.iso8601
      
      # Add group metadata
      hash[:attributes][:group_uid] = group.uid
      hash[:attributes][:group_end_free_trial] = group.free_trial_end_at.utc.iso8601
      hash[:attributes][:group_role] = nil
      
      # Add user metadata
      hash[:attributes][:uid] = user.uid
      hash[:attributes][:virtual_uid] = user.virtual_uid(group)
      hash[:attributes][:email] = user.email
      hash[:attributes][:virtual_email] = user.virtual_email(group)
      hash[:attributes][:name] = user.name
      hash[:attributes][:surname] = user.surname
      hash[:attributes][:country] = user.geo_country_code
      hash[:attributes][:company_name] = user.company
      
      # Permissions
      hash[:attributes][:group_role] = (user.role(group) || 'Guest')
      hash[:attributes][:app_owner] = true
      hash[:attributes][:organizations] = {}

      # Return the hash
      return hash
    end

    # Prepare the SAML response
    # Assertion attributes are populated based on the
    # user, group and app being accessed
    def idp_make_saml_response(user,group)
      assertions = idp_build_user_assertions(user,group)
      
      # Prepare issuer uri
      # Cleanup any remaining parameter we may have
      # added during SSO validation/confirmation
      issuer_uri = request.original_url.gsub(/(&group_id=([^&]*))/,"").gsub(/(&user_uid=([^&]*))/,"")
      
      self.encode_SAMLResponse(assertions[:name_id], {
        attributes: assertions[:attributes],
        issuer_uri: issuer_uri
      })
    end

    # Store location in session
    def store_location
      session[:saml_url] = request.original_url
    end

    # Configure NameId format
    NAME_ID_FORMAT = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
    
    # Prepare the SAML response
    def encode_SAMLResponse(nameID, opts = {})
      now = Time.now.utc
      response_id, reference_id = UUID.generate, UUID.generate
      audience_uri = opts[:audience_uri] || saml_acs_url[/^(.*?\/\/.*?\/)/, 1]
      issuer_uri = opts[:issuer_uri] || (request && request.url) || "http://example.com"
      assertion_attributes = opts[:attributes] || []

      # Additional assertion attributes
      attr_assertions = ""
      assertion_attributes.each do |key,value|
        real_value = ((value.is_a?(Hash) || value.is_a?(Array)) ? value.to_json : value)
        attr_assertions += %[<Attribute Name="#{key}"><AttributeValue>#{real_value}</AttributeValue></Attribute>]
      end

      assertion = %[<Assertion xmlns="urn:oasis:names:tc:SAML:2.0:assertion" ID="_#{reference_id}" IssueInstant="#{now.iso8601}" Version="2.0"><Issuer>#{issuer_uri}</Issuer><Subject><NameID Format="#{NAME_ID_FORMAT}">#{nameID}</NameID><SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><SubjectConfirmationData InResponseTo="#{@saml_request_id}" NotOnOrAfter="#{(now+3*60).iso8601}" Recipient="#{@saml_acs_url}"></SubjectConfirmationData></SubjectConfirmation></Subject><Conditions NotBefore="#{(now-5).iso8601}" NotOnOrAfter="#{(now+60*60).iso8601}"><AudienceRestriction><Audience>#{audience_uri}</Audience></AudienceRestriction></Conditions><AttributeStatement><Attribute Name="mno_uid"><AttributeValue>#{nameID}</AttributeValue></Attribute>#{attr_assertions}</AttributeStatement><AuthnStatement AuthnInstant="#{now.iso8601}" SessionIndex="_#{reference_id}"><AuthnContext><AuthnContextClassRef>urn:federation:authentication:windows</AuthnContextClassRef></AuthnContext></AuthnStatement></Assertion>]

      digest_value = Base64.encode64(algorithm.digest(assertion)).gsub(/\n/, '')

      signed_info = %[<ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-#{algorithm_name}"></ds:SignatureMethod><ds:Reference URI="#_#{reference_id}"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig##{algorithm_name}"></ds:DigestMethod><ds:DigestValue>#{digest_value}</ds:DigestValue></ds:Reference></ds:SignedInfo>]

      signature_value = sign(signed_info).gsub(/\n/, '')

      signature = %[<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">#{signed_info}<ds:SignatureValue>#{signature_value}</ds:SignatureValue><KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#"><ds:X509Data><ds:X509Certificate>#{self.x509_certificate}</ds:X509Certificate></ds:X509Data></KeyInfo></ds:Signature>]

      assertion_and_signature = assertion.sub(/Issuer\>\<Subject/, "Issuer>#{signature}<Subject")

      xml = %[<samlp:Response ID="_#{response_id}" Version="2.0" IssueInstant="#{now.iso8601}" Destination="#{@saml_acs_url}" Consent="urn:oasis:names:tc:SAML:2.0:consent:unspecified" InResponseTo="#{@saml_request_id}" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"><Issuer xmlns="urn:oasis:names:tc:SAML:2.0:assertion">#{issuer_uri}</Issuer><samlp:Status><samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" /></samlp:Status>#{assertion_and_signature}</samlp:Response>]
      
      Base64.encode64(xml)
    end
end
