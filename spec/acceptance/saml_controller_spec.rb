require 'spec_helper'

feature 'SamlController' do

  scenario 'Login via default signup page' do
    saml_request = make_saml_request({issuer: 'appid-1'})
    visit "/api/v1/auth/saml/index?SAMLRequest=#{CGI.escape(saml_request)}"
    # fill_in 'Email', :with => "brad.copa@example.com"
    # fill_in 'Password', :with => "okidoki"
    # click_button 'Sign in'
    # click_button 'Submit' # simulating onload
    # expect(current_url).to eq('http://foo.example.com/saml/consume')
    # expect(page).to have_content("brad.copa@example.com")
  end

end