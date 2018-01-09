# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'nokogiri'
require 'addressable'

require_relative 'tools/logging'
require_relative 'auth/auth_code_flow'
require_relative 'auth/direct_access_flow'

module RbCloak
  # Auth module
  module Auth
    extend Tools::LoggingSupport

    def self.auth_token(flow, url, realm: 'master', **credentials)
      flow_instance = flow(flow, url, realm: realm, **credentials)
      flow_instance&.auth_token
    end

    def self.flow(flow, url, realm: 'master', **credentials)
      log.info("[AUTH] Flow: #{flow} for realm: #{realm} on (#{url})")
      flow_klass = select_flow(flow)
      flow_klass&.new(url, realm: realm, **credentials)
    end

    def self.select_flow(flow)
      if flow.is_a?(GeneralFlow)
        flow
      else
        Auth.const_get(flow.to_sym)
      end
    end
  end
end


