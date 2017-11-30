# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/clients'

describe RbCloak::Clients do
  before(:all) do
    @realm_name = 'test_client_realm'
    @client     = TestConfig.client
    @realms     = RbCloak::Realms.new(@client)
    @realms.create(realm: @realm_name)
    @realm = @realms.read(@realm_name)
  end

  after(:all) do
    @realm.delete
  end

  let(:clients) { @realm.clients }

  let(:client_name) { 'test_client' }
  let(:new_client) { clients.find_by_name(client_name) }

  before do
    clients.create(name: client_name)
  end

  after do
    clients.delete(clients.find_by_name(client_name)[:id])
  end

  describe '#list' do
    let(:client_list) { clients.list }

    it 'will return an array' do
      client_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      list = client_list
      list.wont_be_empty
    end
  end

  describe '#read' do
    it 'will list the client' do
      clients.read(new_client[:id])[:name].must_equal client_name
    end
  end

  # describe '#update' do
  #   it 'will update the client\'s description' do
  #     new_client[:bearerOnly].must_equal false
  #     new_client[:bearerOnly] = true
  #     new_client.update
  #     client_read = clients.read(new_client[:id])
  #     client_read[:bearerOnly].must_equal true
  #   end
  # end

  describe '#create' do
    it 'will list the client' do
      new_client[:name].must_equal client_name
      clients.find_by_name(client_name)[:id].must_equal new_client[:id]
    end

    it 'will create client' do
      new_client[:name].must_equal client_name
    end
  end
end