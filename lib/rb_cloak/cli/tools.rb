# frozen_string_literal: true

module RbCloak
  module Cli
    module Tools
      def self.select_entities(mod = nil, &block)
        mod          ||= RbCloak::Cli::Entities
        entity_classes = mod.constants.select do |c|
          klass = mod.const_get(c)
          klass.is_a?(Class) && !klass.name.include?('Abstract')
        end
        entity_classes = entity_classes.map { |e| mod.const_get(e) }
        return entity_classes unless block_given?
        entity_classes.select { |c| block.call(c) }
      end
    end
  end
end