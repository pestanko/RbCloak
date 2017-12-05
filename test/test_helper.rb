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

  def self.password
    login.split(':')[1]
  end

  def self.username
    login.split(':')[0]
  end

  def self.client
    @client ||= RbCloak::KeycloakClient.new(url, username: username, password: password)
  end

  def self.test_realm(name)
    realm_name = "test_#{name}_realm"
    client     = TestConfig.client
    realms     = RbCloak::Realms.new(client)

    realms.create(realm: realm_name)
    realms.read(realm_name)
  end
end

