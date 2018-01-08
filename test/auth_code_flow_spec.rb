# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/auth'

describe RbCloak::AuthCodeFlow do
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
      RbCloak::AuthCodeFlow.new(TestConfig.url,
                                realm:         @realm[:realm],
                                client_id:     @client[:clientId],
                                client_secret: @client.secret,
                                username:      @user[:username],
                                password:      '123456')
    end

    it 'will be valid flow' do
      auth.token.wont_be_nil
    end
  end
end