# frozen_string_literal: true

require_relative 'commands'
require_relative 'rbcloak_wrapper'

module RbCloak
  module Cli
    module Mixins
      module AbstractListSubMixin
        def print_params(*params)
          @print_params = params
        end

        def p_params
          @print_params
        end

        def print_entity(e, *params)
          params.each do |param|
            print e[param] + ' '
          end
          puts ''
        end

        def execute
          manager.list.each { |e| print_entity(e, *self.class.p_params) }
        end

        def self.included(klass)
          klass.extend self
        end
      end

      module AbstractReadSubMixin
        def find_param(param)
          @find_param = param
        end

        def f_param
          @find_param
        end

        def find_entity
          param    = self.class.f_param.to_sym
          resource = manager.find_by(**{ param => entity })
          if !resource || resource.empty?
            raise ResourceNotFoundError, "Cannot find entity: #{entity}"
          end
          resource
        end

        def execute
          entity = find_entity.first
          print_entity(entity)
        end

        def self.included(klass)
          klass.extend self
        end

        def self.extended(klass)
          klass.parameter 'entity', 'Entity name' if klass.respond_to?(:parameter)
        end
      end

      module AbstractDeleteSubMixin
        include Mixins::AbstractReadSubMixin

        def execute
          entity = find_entity.first
          entity&.delete
        end

        def self.included(klass)
          klass.extend self

          klass.parameter 'entity', 'Entity name' if klass.respond_to?(:parameter)
        end
      end

      module AbstractReadContentSubMixin
        def read_content
          content = if file && FILE.exists?(file)
                      FILE.read(file)
                    else
                      STDIN.read
                    end
          JSON.parse(content, symbolize_names: true)
        end

        def self.included(klass)
          klass.extend self

          klass.parameter 'entity', 'Entity name' if klass.respond_to?(:parameter)
          if klass.respond_to?(:option)
            klass.option ['-f', '--file'], 'FILE', 'JSON Entity spec file', required: false
          end
        end
      end

      module AbstractCreateSubMixin
        include Mixins::AbstractReadContentSubMixin

        def execute
          content = read_content
          manager.create(**content)
        end

        def self.included(klass)
          klass.extend self

          if klass.respond_to?(:option)
            klass.option ['-f', '--file'], 'FILE', 'JSON Entity spec file', required: false
          end
        end
      end

      module AbstractUpdateSubMixin
        include Mixins::AbstractReadSubMixin
        include Mixins::AbstractReadContentSubMixin

        def execute
          entity  = find_entity.first
          content = read_content
          log.debug("UPDATE: #{entity.entity}")
          entity.entity.merge!(content)
          log.debug("UPDATED: #{entity.entity}")
          entity.update
        end

        def self.included(klass)
          klass.extend self

          klass.parameter 'entity', 'Entity name' if klass.respond_to?(:parameter)
          if klass.respond_to?(:option)
            klass.option ['-f', '--file'], 'FILE', 'JSON Entity spec file', required: false
          end
        end
      end
    end
  end
end
