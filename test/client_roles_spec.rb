# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/client_roles'

describe RbCloak::ClientRoles do
  before(:all) do
    @realm = TestConfig.test_realm('client_role')
    @realm.manager.create(name: 'test_client')
    @client = @realm.manager.find_by_name('test_client')
  end

  after(:all) do
    @client.delete
    @realm.delete
  end

  let(:manager) { @client.roles }

  let(:entity_name) { 'test_role' }
  let(:new_entity) { manager.read(entity_name) }

  before do
    manager.create(name: entity_name)
  end

  after do
    new_entity.delete
  end


  describe '#list' do
    let(:roles_list) { manager.list }

    it 'will return an array' do
      roles_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      roles_list.wont_be_empty
    end
  end

  describe '#read' do
    it 'will read the role' do
      manager.read(new_entity[:name])[:id].must_equal new_entity[:id]
    end
  end

  describe '#update' do
    it 'will update the role' do
      new_entity[:description] = 'Some desc'
      new_entity.update
      manager.read(entity_name)[:description].must_equal 'Some desc'
    end
  end

  describe '#create' do
    it 'will create the role' do
      new_entity[:name].must_equal entity_name
    end
  end
end