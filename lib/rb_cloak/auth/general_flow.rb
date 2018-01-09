# frozen_string_literal: true


module RbCloak
  # Auth module
  module Auth
    class InvalidCredentialsError < RuntimeError
    end

    class GeneralFlow
      include Tools::LoggingSupport
      # Initializes the auth provider
      #
      # @param [String] url Url to the keycloak
      # @param [Hash] credentials Credentials object
      def initialize(url, realm: 'master', **credentials)
        @url         = url
        @realm       = realm
        @credentials = credentials
      end

      def credentials
        @credentials
      end

      def token_url
        "#{@url}/auth/realms/#{@realm}/protocol/openid-connect/token"
      end

      def send_token_request(credentials)
        auth_url = token_url
        log.debug("[TOKEN] Endpoint: #{auth_url}")
        response = make_request { RestClient.post auth_url, credentials }
        log.debug("Tokens response: #{response}")
        JSON.parse(response)
      end

      def request_tokens
        send_token_request(credentials)
      end

      # Gets tokens
      #
      # @return [Hash] Tokens
      def tokens
        request_tokens
      end

      def make_request(&block)
        block.call
      rescue RestClient::BadRequest => ex
        log.error("Bad request: #{ex.response}")
        raise InvalidCredentialsError, ex
      rescue RestClient::Found => ex
        ex.response
      end

      def auth_token
        AuthToken.new(self)
      end
    end

    class AuthToken
      def initialize(flow)
        @client = flow
      end

      # Gets tokens
      #
      # @return [Hash] Tokens
      def tokens
        @client.tokens
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
end