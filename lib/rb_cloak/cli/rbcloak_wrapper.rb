# frozen_string_literal: true

require 'clamp'
require 'rb_cloak'
require 'tmpdir'
require 'yaml'

require_relative '../tools/logging'

module RbCloak
  module Cli
    class NotLoggedInError < RuntimeError
    end
    class MissingParamError < RuntimeError
    end

    class Config
      include RbCloak::Tools::LoggingSupport
      def initialize(filepath)
        @path   = filepath
        @config = {}
      end

      def load(path = nil)
        @config.merge!(load_file(path))
      end

      def save(path = nil)
        path ||= @path
        File.open(path, 'w') { |f| f.write @config.to_yaml }
        log.debug("[CFG] Saving config file: #{path}")
      end

      def update(name, value)
        config[name] = value
      end

      def config
        load
        @config
      end

      def [](name)
        name = name.to_s
        config[name]
      end

      def []=(name, value)
        name = name.to_s
        config[name] = value
        save
      end

      def check_param(name)
        val = self[name]
        raise MissingParamError, "Param missing: #{name}" unless val
        val
      end

      private

      def load_file(path = nil)
        path ||= @path
        return {} unless File.exist? path
        log.debug("[CFG] Loading config file: #{path}")
        loaded = YAML::load_file(path)
        log.debug("[CFG] Loaded: #{loaded}")
        loaded
      end
    end

    class RbCloakWrapper
      CONFIG_FILE = '.rbcloak_config'
      extend RbCloak::Tools::LoggingSupport

      def self.instance
        @instance ||= self.new
      end

      def temp_dir
        Dir.tmpdir
      end

      def config_file
        File.join(temp_dir, CONFIG_FILE)
      end

      def url
        config.check_param('url')
      end

      def username
        config.check_param('username')
      end

      def password
        config.check_param('password')
      end

      def credentials(url:, username:, password:)
        config[:url]      = url
        config[:username] = username
        config[:password] = password
        config.save
      end

      def config
        @config ||= Config.new(config_file)
      end

      def client
        @client ||= RbCloak::KeycloakClient.new(url,
                                                username: username,
                                                password: password)
      end
    end
  end
end