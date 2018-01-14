# frozen_string_literal: true

require_relative '../test_helper'

describe 'RbCloak CLI Users' do
  before(:all) do
    @realm = TestConfig.test_realm('cli_users')
  end

  after(:all) do
    @realm.delete
  end

  let(:manager) { @realm.users }
  let(:realm_name) { @realm[:realm] }

  let(:entity_name) { 'test_user' }
  let(:new_entity) { manager.find_by_name(entity_name) }

  before do
    manager.create(username: entity_name)
  end

  after do
    manager.delete(manager.find_by_name(entity_name)[:id])
  end

  describe '#list' do
    let(:entity_list) { TestConfig.cli(" users list --realm #{realm_name}") }

    it 'will list a test entity' do
      entity_list.must_include entity_name
    end
  end

  describe '#read' do
    let(:entity_read) { TestConfig.cli(" users read --realm #{realm_name} #{entity_name}") }
    it 'will list the user' do
      parsed = JSON.parse(entity_read)['username']
      parsed.must_equal entity_name
    end
  end

  describe '#delete' do
    let(:new_entity_name) { 'user_to_delete' }
    let(:new_delete_entity) do
      manager.create(
        username: new_entity_name
      )
      manager.find_by_name(new_entity_name)
    end

    it 'will delete a user' do
      TestConfig.cli("users delete -v --realm #{realm_name} #{new_delete_entity[:username]}")
      manager.find_by_name(new_delete_entity[:username]).must_be_nil
    end
  end


  describe '#create' do
    # TODO
  end
end