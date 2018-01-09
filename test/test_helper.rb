$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rb_cloak'
require 'minitest/hooks/default'
require 'minitest/autorun'

module TestConfig
  def self.url
    @url ||= ENV['KEYCLOAK_URL'] || 'http://localhost:8080'
  end

  def self.login
    @login ||= ENV['KEYCLOAK_LOGIN'] || 'admin:admin'
  end

  def self.credentials
    {
      username: username,
      password: password,
      grant_type: 'password',
      client_id: 'admin-cli',
    }
  end

  def self.client_credentials
    {
      client_id: client_id,
      client_secret: client_secret,
      grant_type: 'client_credentials',
    }
  end

  def self.client_id
    @client_id ||= ENV['KEYCLOAK_CLIENT_ID'] || 'admin-api-client'
  end

  def self.client_secret
    @client_secret ||= ENV['KEYCLOAK_CLIENT_SECRET'] || '88cd8603-cf39-41ef-8e09-0719b91bcf9f'
  end

  def self.password
    login.split(':')[1]
  end

  def self.username
    login.split(':')[0]
  end

  def self.client
    #@client ||= RbCloak::KeycloakClient.new(url, client_id: client_id, client_secret: client_secret)
    @client ||= RbCloak::KeycloakClient.new(url, username: username, password: password)
  end

  def self.test_realm(name)
    realm_name = "test_#{name}_realm"
    client     = TestConfig.client
    realms     = RbCloak::Realms.new(client)

    realms.create(realm: realm_name, enabled: true)
    realms.read(realm_name)
  end

  def self.test_client(realm, client_name, **params)
    client_name = "test_#{client_name}_client"
    realm.clients.create(name: client_name, clientId: client_name, **params)
    realm.clients.find_by_client_id(client_name)
  end

  def self.test_client_with_realm(name, **params)
    realm = test_realm(name)
    client = test_client(realm, name, **params)
    [realm, client]
  end

  def self.test_user(realm, username, **params)
    username = "test_#{username}_user"
    realm.users.create(username: username, enabled: true, emailVerified: true, **params)
    user = realm.users.find_by_name(username)
    user.password('123456')
    user
  end
end

