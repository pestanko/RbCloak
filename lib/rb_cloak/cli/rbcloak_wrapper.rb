# frozen_string_literal: true

require 'clamp'
require_relative 'entities'
require_relative 'tools'
require_relative '../tools/logging'

module RbCloak
  module Cli
    class RbCloakWrapper
      extend RbCloak::Tools::LoggingSupport
      def self.instance
        @instance ||= self.new
      end
    end
  end
end