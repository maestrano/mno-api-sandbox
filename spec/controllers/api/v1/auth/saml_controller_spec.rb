require 'spec_helper'

module Api

	module V1

		module Auth

      describe SamlController do

        let!(:app) { App.create!(name: 'TestApp') }
        let!(:group) { Group.create!(name: 'TestGroup', app: app, app_id: app.id) }
        let!(:user) { User.create!(email: 'jsmith@example.com', name: 'John', surname: 'Smith', geo_country_code: 'AU', company: 'Maestrano') }
        let!(:user_group) { GroupUserRel.create!(user: user, group: group, role: 'Member') }

        let(:saml_request) { make_saml_request({issuer: app.uid}) }

        describe 'index' do

          context 'invalid SAML request' do
            subject { get :index, :SAMLRequest => make_saml_request({issuer: 'whatever'}) }
            
            it { expect(subject.body).to eql "Wrong APP ID! The API app_id parameter is likely to be misconfigured." }
          end

          context 'unauthenticated user' do
            subject { get :index, :SAMLRequest => saml_request }
            
            it { expect(subject).to render_template('api/v1/auth/select_user_to_login') }
          end

          context 'authenticated user' do
            subject! { get :index, :SAMLRequest => saml_request, user_uid: user.uid }

            it { expect(subject).to render_template('saml_idp/idp/saml_post') }

            it { expect(extract_value(assigns[:saml_response], 'mno_uid').text).to eql(user.uid) }
            it { expect(extract_value(assigns[:saml_response], 'group_uid').text).to eql(group.uid) }
            it { expect(extract_value(assigns[:saml_response], 'group_role').text).to eql(user_group.role) }
            it { expect(extract_value(assigns[:saml_response], 'uid').text).to eql(user.uid) }
            it { expect(extract_value(assigns[:saml_response], 'virtual_uid').text).to eql("#{user.uid}.#{group.uid}") }
            it { expect(extract_value(assigns[:saml_response], 'email').text).to eql(user.email) }
            it { expect(extract_value(assigns[:saml_response], 'name').text).to eql(user.name) }
            it { expect(extract_value(assigns[:saml_response], 'surname').text).to eql(user.surname) }
            it { expect(extract_value(assigns[:saml_response], 'country').text).to eql(user.geo_country_code) }
            it { expect(extract_value(assigns[:saml_response], 'company_name').text).to eql(user.company) }
          end

        end

        def extract_value(saml_response, node_name)
          doc = Nokogiri::XML(Base64.decode64(saml_response))
          doc.remove_namespaces!
          doc.at_xpath("//AttributeStatement/Attribute[@Name='#{node_name}']/AttributeValue")
        end
      end

    end

  end

end