# frozen_string_literal: true

require 'rest-client'
require 'json'

require_relative 'tools/logging'

module RbCloak
  # Defaults client
  class Defaults
    include Tools::LoggingSupport
    attr_reader :client

    def auth
      client.auth
    end

    def initialize(client)
      @client = client
    end

    def authorization_header
      { Authorization: "Bearer #{auth.access_token}" }
    end

    def headers
      { 'Content-Type' => 'application/json' }.merge(authorization_header)
    end

    def url
      "#{client.url}/auth/admin"
    end

    def list
      log.info("Listing #{manager_name}: #{url}")
      result = make_request { RestClient.get(url, headers) }
      log.debug("List response: #{result}")
      create_instance result
    end

    def create(**params)
      log.info("Creating #{resource_name} (#{url}): #{params}")
      result = make_request { RestClient.post(url, JSON.dump(params), headers) }
      log.debug("Create response: #{result}")
      result
    end

    # Default delete function
    def delete(id)
      path = "#{url}/#{id}"
      log.info("Delete #{resource_name}: #{path}")
      make_request { RestClient.delete(path, headers) }
      true
    end

    def read(id)
      path = "#{url}/#{id}"
      log.info("Reading #{resource_name}: #{path}")
      res = make_request{ RestClient.get(path, headers) }
      log.debug("Reading response: #{res}")
      create_instance res
    end

    def find_by_name(name)
      res = list.select { |e| e.entity_name == name }
      res[0] unless res.empty?
    end

    def find(&block)
      list.select block
    end

    def find_by(**params)
      list.select { |e| params.all? { |k, v| e[k] == v } }
    end

    # @api public
    # Updates existing resource
    #
    # @param [Hash, Default] attributes Attributes that will be updated
    # @return [DefaultResource] Updated resource
    def update(attributes, id: nil, method: :put)
      id ||= attributes[:id]
      path = url
      path = "#{path}/#{id}" unless id.nil?
      log.info("Updating [#{path}]: #{attributes}")
      body = JSON.dump(attributes)
      make_request { RestClient.method(method).call(path, body, headers) }
    rescue StandardError => ex
      log.error(ex.response)
    end

    def resource_name
      manager_name.chomp('s')
    end

    def resource_klass
      RbCloak.const_get(resource_name.to_sym)
    end

    def manager_name
      self.class.name.split('::').last
    end

    def create_instance(response)
      content = JSON.parse(response.body, symbolize_names: true)
      if content.is_a?(Array)
        content.each_with_object([]) do |entity, obj|
          obj << _create_entity(entity)
        end
      else
        _create_entity content
      end
    end

    def _create_entity(entity)
      log.debug("Creating entity of #{resource_name}: #{entity}")
      resource_klass.new(self, entity)
    end

    def make_request(&block)
      block.call
    rescue RestClient::Unauthorized
      auth.invalidate
      make_request(&block)
    rescue StandardError => ex
      log.error(ex.response)
      ex.response
    end
  end

  # Default resource
  class Default
    attr_reader :client

    def url
      "#{@client.url}/#{entity_id}"
    end

    # @param [object] client
    # @param [Hash] entity
    def initialize(client, entity)
      @client    = client
      @entity    = entity
    end

    def entity_id
      @entity[:id]
    end

    def entity_name
      @entity[:name]
    end

    def entity
      read unless @entity
      @entity
    end

    def delete
      @client.delete(entity_id)
    end

    def update
      @client.update(@entity, id: entity_id)
    end

    def read
      ent = @client.read(entity_id)
      @entity = ent.entity
    end

    def to_s
      @entity.to_s
    end

    def manager_instance(manager, *args)
      manager.new(@client, self, *args)
    end

    # @api public
    # Access properties of the resource contained in the entity
    #
    # @param [String] key Name of the property
    # @return [object] Value of the property
    def [](key)
      entity[key.to_sym]
    end

    # @api public
    # Set property value of the resource contained in the entity
    #
    # @param [String] key Name of the property
    # @param [String] value Value of the property
    # @return [object] Value of the property
    def []=(key, value)
      ley = key.to_sym
      entity[ley] = value
    end

    # Respond to method missing
    #
    # If symbol is not defined in current class, it will be forwarded to entity hash
    # @param [Symbol, String] symbol Method name
    # @return [Bool] true if responds, false otherwise
    def respond_to_missing?(symbol, *_)
      entity.respond_to?(symbol) || entity.key?(symbol)
    end

    # Method missing implementation
    #
    # @param [Symbol, String] symbol Method name
    # @param [Array] args Arguments passed to method
    # @param [Block] block Block passed to method
    def method_missing(symbol, *args, &block)
      if entity.key?(symbol)
        entity[symbol]
      elsif entity.respond_to?(symbol)
        entity.send(symbol, *args, &block)
      else
        super
      end
    end
  end
end
