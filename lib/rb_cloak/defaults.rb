# frozen_string_literal: true

require 'rest-client'
require 'json'

require_relative 'tools/logging'

module RbCloak
  # Defaults client
  class Defaults
    include Tools::LoggingSupport
    attr_reader :client

    class RbCloakError < RuntimeError; end

    class CannotCreateResourceError < RbCloakError
    end

    def fail_on_bad_request?
      client.fail_on_bad_request?
    end

    # Gets an auth object
    #
    # @return [RbCloak::Auth] Auth object instance
    def auth
      client.auth
    end

    def initialize(client)
      @client = client
    end

    # Gets the authorization header
    #
    # @return [Hash] Authorization header
    def authorization_header
      { Authorization: "Bearer #{auth.access_token}" }
    end

    # Gets the header with a Content type json and merged with an authorization header
    #
    # @return [Hash] Content type and an authorization header
    def headers
      { 'Content-Type' => 'application/json' }.merge(authorization_header)
    end

    # Gets url
    #
    # @return [String] Url to receive an resource
    def url
      "#{client.url}/auth/admin"
    end

    # Lists a resources
    #
    # @return [List] List of resources
    def list
      log.debug("Listing #{manager_name}: #{url}")
      result = make_request { RestClient.get(url, headers) }
      log.debug("List response: #{result}")
      create_instance result
    end

    # Creates a resource
    #
    # @param [Hash] params Parameters to create parameters
    def create(**params)
      log.info("Creating #{resource_name} (#{url}): #{params}")
      result = make_request { RestClient.post(url, JSON.dump(params), headers) }
      log.debug("Create response: #{result}")
      result
    end

    # Default delete function
    #
    # @param [Fixnum] id Id of a resource
    def delete(id)
      path = "#{url}/#{id}"
      log.info("Delete #{resource_name}: #{path}")
      make_request { RestClient.delete(path, headers) }
      true
    end

    # Reads an resource
    #
    # @param [Fixnum] id Id of a resource
    # @return [RbShift::Default] Resource instance
    def read(id)
      path = "#{url}/#{id}"
      log.debug("Reading #{resource_name}: #{path}")
      res = make_request{ RestClient.get(path, headers) }
      log.debug("Reading response: #{res}")
      create_instance res
    end

    # Finds a resource by name
    #
    # @param [String] name Name of the resource
    # @return [RbShift::Default] Resource instance
    def find_by_name(name)
      res = find { |e| e.entity_name == name }
      res[0] unless res.empty?
    end

    # Finds resources by given condition in block
    #
    # @param [Block] block Block with a condition
    # @return [List] list of the resources
    def find(&block)
      list.select(&block)
    end

    # Finds by parameters
    #
    # @param [Hash] params Parameters to filter by
    # @return [List] list of the resources
    def find_by(**params)
      find { |e| params.all? { |k, v| e[k] == v } }
    end

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
      raise RbCloakError, ex if fail_on_bad_request?
    end

    # Gets a resource name
    #
    # @return [String] Resource name
    def resource_name
      manager_name.chomp('s')
    end

    # Gets a resource klass
    #
    # @return [Class] Resource klass
    def resource_klass
      RbCloak.const_get(resource_name.to_sym)
    end

    def manager_name
      self.class.name.split('::').last
    end

    # Creates an instance of the klass (resource)
    #
    # @param [Hash] response Response hash
    # @param [Class] klass Resource class
    # @return [RbCloak::Default]
    def create_instance(response, klass: nil, manager_bind: self)

      if response.strip.empty?
        raise CannotCreateResourceError, 'Response is empty, cannot create instance'
      end

      content = JSON.parse(response.body, symbolize_names: true)
      if content.is_a?(Array)
        content.each_with_object([]) do |entity, obj|
          obj << _create_entity(entity, klass: klass, bind: manager_bind)
        end
      else
        _create_entity(content, klass: klass, bind: manager_bind)
      end
    end

    # Wraps an request to invalidate access token and logs an invalid response
    #
    # @param [Block] block Request call to be wrapped
    # @return [RestClient::Response] response for the request
    def make_request(&block)
      block.call
    rescue RestClient::Unauthorized
      auth.invalidate
      make_request(&block)
    rescue StandardError => ex
      log.error("[#{ex}] #{ex.response}")
      ex.response
    end

    private

    def _create_entity(entity, klass: nil, bind: self)
      klass ||= resource_klass
      log.debug("Creating entity of #{resource_name}: #{entity}")
      klass.new(bind, entity)
    end
  end

  # Default resource
  class Default
    attr_reader :client

    def url
      "#{@client.url}/#{entity_id}"
    end

    # Initializes an resource
    #
    # @param [object] client Resource client
    # @param [Hash] entity Parameters of the resource
    def initialize(client, entity)
      @client    = client
      @entity    = entity
    end

    # Gets an entity id
    #
    # @return [String, Fixnum] entity id
    def entity_id
      @entity[:id]
    end

    # Gets an entity name
    #
    # @return [String, Fixnum] entity name
    def entity_name
      @entity[:name]
    end

    # Gets an internal parameters hash
    #
    # @return [Hash] entity hash
    def entity
      read unless @entity
      @entity
    end

    # Deletes an resource
    def delete
      @client.delete(entity_id)
    end

    # Updates an resource
    def update
      @client.update(@entity, id: entity_id)
    end

    # Reads a resource again
    def read
      ent = @client.read(entity_id)
      @entity = ent.entity
    end

    def to_s
      @entity.to_s
    end

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
