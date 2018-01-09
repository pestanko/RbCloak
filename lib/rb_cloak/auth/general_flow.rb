# frozen_string_literal: true


module RbCloak
  # Auth module
  module Auth
    class InvalidCredentialsError < RuntimeError
    end
    # Parent class of the flows
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

      # Returns the credentials
      #
      # @return [Hash] Credentials
      def credentials
        @credentials
      end

      # Returns the url to obtain the token
      #
      # @return [String] Token url
      def token_url
        "#{@url}/auth/realms/#{@realm}/protocol/openid-connect/token"
      end

      # Gets tokens
      #
      # @return [Hash] Tokens
      def tokens
        request_tokens
      end

      # Send the request to obtain token
      #
      # @param [Hash] credentials Credentials
      def send_token_request(credentials)
        auth_url = token_url
        log.debug("[TOKEN] Endpoint: #{auth_url}")
        response = check_request { RestClient.post auth_url, credentials }
        log.debug("Tokens response: #{response}")
        JSON.parse(response)
      end

      # Request tokens
      #
      # @return [Hash] Tokens
      def request_tokens
        send_token_request(credentials)
      end

      # Checks the request
      #
      # If the request throws an exception, it will logs it and extracts the response
      def check_request(&block)
        block.call
      rescue RestClient::Found => ex
        ex.response
      rescue RestClient::Exception => ex
        log.error("Bad request: #{ex.response}")
        raise InvalidCredentialsError, ex.response
      end

      # Creates authentication token instance
      #
      # @return [AuthToken] Auth token instance
      def auth_token
        AuthToken.new(self)
      end
    end

    class AuthToken
      # Creates instance of the auth token
      #
      # Wrapper class abstraction that holds the flow to obtain the the tokens
      # with ability to invalidate the tokens
      # @param [GeneralFlow] flow Flow instance
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