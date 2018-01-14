# frozen_string_literal: true

require_relative '../test_helper'

describe 'RbCloak CLI Client' do
  before(:all) do
    @realm = TestConfig.test_realm('cli_client')
  end

  after(:all) do
    @realm.delete
  end

  let(:manager) { @realm.clients }
  let(:realm_name) { @realm[:realm] }

  let(:entity_name) { 'test_client' }
  let(:new_entity) { manager.find_by_name(entity_name) }

  before do
    manager.create(name: entity_name, clientId: entity_name)
  end

  after do
    manager.delete(manager.find_by_name(entity_name)[:id])
  end

  describe '#list' do
    let(:entity_list) { TestConfig.cli(" clients list --realm #{realm_name}") }

    it 'will list a test entity' do
      entity_list.must_include entity_name
    end
  end

  describe '#read' do
    let(:entity_read) { TestConfig.cli(" clients read --realm #{realm_name} #{entity_name}") }
    it 'will list the client' do
      parsed = JSON.parse(entity_read)['clientId']
      parsed.must_equal entity_name
    end
  end

  describe '#secret' do
    # TODO
  end

  describe '#create' do
    # TODO
  end
end