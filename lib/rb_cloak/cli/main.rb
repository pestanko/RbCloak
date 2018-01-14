# frozen_string_literal: true

require 'clamp'
require_relative 'entities'
require_relative 'tools'
require_relative '../tools/logging'
require_relative 'login'

module RbCloak
  module Cli
    class MainCommand < AbstractCommand
      extend RbCloak::Tools::LoggingSupport
      class << self
        def load_entities
          entities = Tools.select_entities { |e| !e.name.include?('SubCommand') }
          entities.each do |entity_command|
            log.debug("[SUB] Main: #{entity_command.command} - #{entity_command}")
            subcommand entity_command.command, entity_command.description, entity_command
          end
        end
      end

      load_entities

      subcommand 'login', 'Provide login information for the keycloack', LoginCommand
      subcommand 'logout', 'Logout the keycloack', LogoutCommand
    end
  end
end