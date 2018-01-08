# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/auth'

describe RbCloak::Auth do
  describe '#token' do
    let(:url) { TestConfig.url }
    let(:credentials) { TestConfig.credentials }
    let(:client_credentials) { TestConfig.client_credentials }
    let(:auth) { RbCloak::Auth.new(url, credentials) }
    let(:auth_client) { RbCloak::Auth.new(url, client_credentials) }

    it 'will return valid token for valid client credentials' do
      auth_client.access_token.wont_be_nil
    end

    it 'will return valid token for valid credentials' do
      auth.access_token.wont_be_nil
    end

    it 'will throw an exception invalid credentials' do
      assert_raises(RbCloak::Auth::InvalidCredentialsError) do
        RbCloak::Auth.new(url, {}).access_token
      end
    end
  end
end