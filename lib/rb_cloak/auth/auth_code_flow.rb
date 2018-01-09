# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'nokogiri'
require 'addressable'

require_relative 'general_flow'

module RbCloak
  module Auth
    class AuthCodeFlow < GeneralFlow
      attr_reader :url, :realm, :client_id, :client_secret, :password, :username

      # Initialize the Auth code flow
      #
      # @param [String] url Base url
      # @param [String] realm Realm name
      # @param [String] client_id Client id
      # @param [String] client_secret Client secret
      # @param [String] password User's password
      # @param [String] username Username
      def initialize(url, realm:, client_id:, client_secret:, password:, username:,
                     redirect_uri: nil)
        @redirect_uri  = redirect_uri || 'http://localhost:5000/'
        @url           = url
        @realm         = realm
        @client_id     = client_id
        @client_secret = client_secret
        @password      = password
        @username      = username
      end

      # Url to obtain the code
      def auth_url
        "#{@url}/auth/realms/#{@realm}/protocol/openid-connect/auth"
      end

      # Token credentials
      #
      # @param [String] code Code to obtain token
      # @param [String] session_state Session state
      def build_token_credentials(code, session_state)
        {
          code:                 code,
          client_session_state: session_state,
          scope:                'code',
          grant_type:           'authorization_code',
        }.merge(client_credentials)
      end

      # Client credentials - client_id, client_secret
      def client_credentials
        {
          client_id:     @client_id,
          client_secret: @client_secret,
          redirect_uri:  @redirect_uri,
        }
      end

      # Form credentials, username and password to be used to authenticate the user
      def form_credentials
        {
          username: @username,
          password: @password,
        }
      end

      # Credentials to obtain the code
      def code_auth_credentials
        {
          response_type: 'code',
        }.merge(client_credentials)
      end

      # Requests the authentication code
      # @return [(String, String)] Tuple: (Code, session_state)
      def request_code
        auth_response = auth_request
        action_url    = parse_form_action(auth_response)
        cookies       = auth_response.cookies
        redirect      = send_form_with_code(action_url, cookies)
        parse_code(redirect)
      end

      # Requests the authentication tokens
      def request_tokens
        code, session_state = request_code
        params              = build_token_credentials(code, session_state)
        send_token_request(params)
      end

      private

      def parse_form_action(response)
        root   = Nokogiri::HTML(response)
        form   = root.css('form')[0]
        action = form['action']&.to_s
        log.debug("Form's action: #{action}")
        action
      end

      def auth_request
        url = auth_url
        log.info("Auth url: #{url}: #{code_auth_credentials}")
        params = { params: code_auth_credentials }
        check_request { RestClient.get(url, params) }
      end

      def send_form_with_code(url, cookies)
        log.info("Code url: #{url}")
        cookies  = { cookies: cookies }
        response = check_request { RestClient.post(url, form_credentials, cookies) }

        log.debug("Code response: #{response}")
        response
      end

      def parse_code(redirect)
        headers       = redirect.headers
        location      = headers[:location]
        parsed        = Addressable::URI.parse(location)
        query_params  = parsed.query_values
        code          = query_params['code']
        session_state = query_params['session_state']
        log.debug("Parsed code: #{code}, session_state: #{session_state}")
        [code, session_state]
      end
    end
  end
end


