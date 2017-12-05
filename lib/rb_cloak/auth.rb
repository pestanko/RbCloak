# frozen_string_literal: true

require 'rest-client'
require 'json'

require_relative 'tools/logging'

module RbCloak
  # Auth provider
  class Auth
    include Tools::LoggingSupport

    class InvalidCredentialsError < RuntimeError; end

    # Initializes the auth provider
    #
    # @param [String] url Url to the keycloak
    # @param [Hash] credentials Credentials object
    def initialize(url, credentials)
      @url = url
      @credentials = credentials
    end

    # Gets tokens
    #
    # @return [Hash] Tokens
    def tokens
      auth_url = "#{@url}/auth/realms/master/protocol/openid-connect/token"
      log.debug("AuthUrl: #{auth_url}")
      response = RestClient.post auth_url, @credentials
      log.debug(response)
      JSON.parse(response.body)
    rescue RestClient::BadRequest => ex
      log.error("Bad request: #{ex}: #{ex.response}")
      raise RbCloak::Auth::InvalidCredentialsError, ex
    end

    # Gets access token
    #
    # @return [String] Access token
    def access_token
      @access_token ||= tokens['access_token']
    end

    # Invalidates an access token
    def invalidate
      @access_token = nil
    end
  end
end


