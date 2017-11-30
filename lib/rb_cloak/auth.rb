# frozen_string_literal: true

require 'rest-client'
require 'json'

require_relative 'tools/logging'

module RbCloak
  class Auth
    include Tools::LoggingSupport

    class InvalidCredentialsError < RuntimeError; end

    def initialize(url, credentials)
      @url = url
      @credentials = credentials
    end

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

    def access_token
      @access_token ||= tokens['access_token']
    end

    def invalidate
      @access_token = nil
    end
  end
end


