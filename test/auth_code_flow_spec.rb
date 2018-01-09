# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/auth'

describe RbCloak::Auth::AuthCodeFlow do
  describe '#token' do

    before(:all) do
      @realm, @client = TestConfig.test_client_with_realm('auth_code_flow',
                                                          redirectUris: ['http://localhost:5000/'])
      @user           = TestConfig.test_user(@realm, 'auth-user')
    end

    after(:all) do
      @client.delete
      @realm.delete
    end

    let(:auth) do
      RbCloak::Auth::AuthCodeFlow.new(TestConfig.url,
                                      realm:         @realm[:realm],
                                      client_id:     @client.client_id,
                                      client_secret: @client.secret,
                                      username:      @user[:username],
                                      password:      '123456')
    end

    let(:auth_token) { auth.auth_token }

    it 'will be valid flow' do
      auth_token.access_token.wont_be_nil
    end
  end
end