# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/auth'

describe RbCloak::Auth do
  describe '#token' do
    let(:url) { TestConfig.url }
    let(:credentials) { TestConfig.credentials }
    let(:client_credentials) { TestConfig.client_credentials }
    let(:auth) { RbCloak::Auth.auth_token(:DirectAccessFlow, url, **credentials) }
    let(:auth_client) { RbCloak::Auth.auth_token(:DirectAccessFlow, url, client_credentials) }

    it 'will return valid token for valid client credentials' do
      auth_client.access_token.wont_be_nil
    end

    it 'will return valid token for valid credentials' do
      auth.access_token.wont_be_nil
    end

    it 'will throw an exception invalid credentials' do
      assert_raises(RbCloak::Auth::InvalidCredentialsError) do
        RbCloak::Auth.auth_token(:DirectAccessFlow, url, username: 'noneUser',
                                 password: '1111111-111')
          .access_token
      end
    end
  end
end