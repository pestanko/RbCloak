# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'nokogiri'
require 'addressable'

require_relative 'tools/logging'

module RbCloak
  # Auth provider
  class Auth
    include Tools::LoggingSupport

    class InvalidCredentialsError < RuntimeError;
    end

    # Initializes the auth provider
    #
    # @param [String] url Url to the keycloak
    # @param [Hash] credentials Credentials object
    def initialize(url, credentials, realm: 'master')
      @url         = url
      @realm       = realm
      @credentials = credentials
    end

    # Gets tokens
    #
    # @return [Hash] Tokens
    def tokens
      auth_url = "#{@url}/auth/realms/#{@realm}/protocol/openid-connect/token"
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

  class AuthCodeFlow
    attr_reader :url, :realm, :client_id, :client_secret, :password, :username

    include Tools::LoggingSupport

    def initialize(url, realm:, client_id:, client_secret:, password:, username:)
      @url           = url
      @realm         = realm
      @client_id     = client_id
      @client_secret = client_secret
      @password      = password
      @username      = username
    end

    def auth_url
      "#{@url}/auth/realms/#{@realm}/protocol/openid-connect/auth"
    end

    def token_url
      "#{@url}/auth/realms/#{@realm}/protocol/openid-connect/token"
    end

    def client_auth
      {
        client_id:     @client_id,
        client_secret: @client_secret,
        redirect_uri:  'http://localhost:5000/',
      }
    end

    def auth_credentials
      {
        response_type: 'code',
      }.merge(client_auth)
    end

    def auth_request
      url = auth_url
      log.info("Auth url: #{url}: #{auth_credentials}")
      response = RestClient.get(url, { params: auth_credentials })
      log.debug("Auth cookies: #{response.cookies}")
      parse_auth_response(response)
    end

    def code_request
      url, cookies = auth_request
      form         = {
        username: @username,
        password: @password,
      }

      log.info("Code url: #{url}")

      response = make_request { RestClient.post(url, form, { cookies: cookies }) }

      log.debug("Code response: #{response}")
      response.headers
    end

    def code_params(code, session_state)
      {
        code:                 code,
        client_session_state: session_state,
        scope:                'code',
        grant_type:           'authorization_code',
      }.merge(client_auth)
    end

    def parse_code(request)
      location      = request[:location]
      parsed        = Addressable::URI.parse(location)
      query_params  = parsed.query_values
      code          = query_params['code']
      session_state = query_params['session_state']
      [code, session_state]
    end

    def make_request(&block)
      begin
        block.call
      rescue RestClient::BadRequest => ex
        log.error(ex.response)
        ex.response
      rescue RestClient::Found => ex
         ex.response
      end
    end

    def request_token
      code_req            = code_request
      code, session_state = parse_code(code_req)
      url                 = token_url
      params              = code_params(code, session_state)

      log.info("Token url: #{url}: #{params}")
      response = make_request { RestClient.post(url, params) }
      log.info("Response: #{response}")
      response
    end

    def token
      request = request_token
      body    = JSON.parse(request.body)
      token   = body['access_token']
      log.info("Access token: #{token}")
      token
    end

    private

    def parse_auth_response(response)
      root   = Nokogiri::HTML(response)
      form   = root.css('form')[0]
      action = form['action']&.to_s
      log.debug("Form's action: #{action}")
      [action, response.cookies]
    end
  end
end


