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

      def client_auth
        {
          client_id:     @client_id,
          client_secret: @client_secret,
          redirect_uri:  'http://localhost:5000/',
        }
      end

      def form_params
        {
          username: @username,
          password: @password,
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
        params   = { params: auth_credentials }
        response = make_request { RestClient.get(url, params) }
        parse_auth_response(response)
      end

      def request_code
        url, cookies = auth_request

        log.info("Code url: #{url}")
        cookies  = { cookies: cookies }
        response = make_request { RestClient.post(url, form_params, cookies) }

        log.debug("Code response: #{response}")
        response.headers
      end

      def token_credentials(code, session_state)
        {
          code:                 code,
          client_session_state: session_state,
          scope:                'code',
          grant_type:           'authorization_code',
        }.merge(client_auth)
      end

      private

      def parse_auth_response(response)
        root   = Nokogiri::HTML(response)
        form   = root.css('form')[0]
        action = form['action']&.to_s
        log.debug("Form's action: #{action}")
        [action, response.cookies]
      end

      def request_tokens
        code, session_state = parse_code(request_code)
        params              = token_credentials(code, session_state)
        send_token_request(params)
      end

      def parse_code(request)
        location      = request[:location]
        parsed        = Addressable::URI.parse(location)
        query_params  = parsed.query_values
        code          = query_params['code']
        session_state = query_params['session_state']
        [code, session_state]
      end
    end
  end
end


