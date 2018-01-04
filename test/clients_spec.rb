# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/clients'

describe RbCloak::Clients do
  before(:all) do
    @realm = TestConfig.test_realm('client')
  end

  after(:all) do
    @realm.delete
  end

  let(:manager) { @realm.clients }

  let(:entity_name) { 'test_client' }
  let(:new_entity) { manager.find_by_name(entity_name) }

  before do
    manager.create(name: entity_name)
  end

  after do
    manager.delete(manager.find_by_name(entity_name)[:id])
  end

  describe '#list' do
    let(:client_list) { manager.list }

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
      manager.read(new_entity[:id])[:name].must_equal entity_name
    end
  end

  describe '#secret' do
    it 'will show the client secret' do
      new_entity.secret.wont_be_nil
    end
  end

  describe '#create' do
    it 'will list the client' do
      new_entity[:name].must_equal entity_name
      manager.find_by_name(entity_name)[:id].must_equal new_entity[:id]
    end

    it 'will create client' do
      new_entity[:name].must_equal entity_name
    end
  end
end