# frozen_string_literal: true

require 'logger'

module RbCloak
  module Tools
    # Custom logging module
    module LoggingSupport
      def self.set_level(level)
        default_factory.set_level(level)
      end

      def self.default_factory
        @default_factory ||= LoggingFactory.new('KEYCLOAK_ADMIN_LOG_LEVEL')
      end

      # @api public
      # Logger instance
      #
      # @return [Logger] Logger
      def log
        @log = LoggingSupport.default_factory.get_logger(name: log_name)
      end

      def log_name(name = nil)
        @log_name = name || @log_name || self.class.name
      end

      def self.included(klass)
        klass.extend(self)
      end

      def self.extended(klass)
        klass.log_name(klass.name)
      end

      # Creates instances of the logger
      class LoggingFactory
        def initialize(env_var_name)
          @env_var_name = env_var_name
        end

        # @api public
        # Creates a instance of logger using in config information
        #
        # @param [String] log_level Override default log level using in config or ENV
        # @return [Logger] Logger instance
        def get_logger(log_level: nil, name: nil)
          log          = Logger.new(STDERR)
          log.progname = name || self.name
          log_level    = log_level || ENV[@env_var_name] || @log_level || 'debug'
          log.level    = get_level log_level
          logging_format log
        end

        def set_level(level)
          @log_level = level
        end

        # @api public
        # Gets logging logging level number
        #
        # @param [String] log_level Logging level as string is 'debug'
        # @return [Fixnum] Log level id
        def get_level(log_level = 'debug')
          Logger.const_get log_level.to_s.upcase
        rescue NameError
          Logger::DEBUG
        end

        # Sets logging format for specified logger
        #
        # @param [Logger] logger Logger for which the formatter will be set
        # @return [Logger] modified logger instance
        def logging_format(logger)
          default_formatter = Logger::Formatter.new
          logger.formatter  = proc do |severity, datetime, progname, msg|
            default_formatter.call(severity, datetime, "(#{progname})", msg.to_s)
          end
          logger
        end
      end
    end
  end
end
