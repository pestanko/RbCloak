# frozen_string_literal: true

require_relative 'test_helper'

require 'keycloak_admin/auth'

describe KeycloakAdmin::Auth do
  describe '#token' do
    let(:url) do
      TestConfig.url
    end

    let(:credentials) do
      TestConfig.credentials
    end

    let(:auth) do
      KeycloakAdmin::Auth.new(url, credentials)
    end

    it 'will return valid token for valid credentials' do
      auth.access_token.wont_be_nil
    end

    it 'will throw an exception invalid credentials' do
      assert_raises(KeycloakAdmin::Auth::InvalidCredentialsError) do
        KeycloakAdmin::Auth.new(url, {}).access_token
      end
    end
  end
end