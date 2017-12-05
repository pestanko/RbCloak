# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/client_templates'

describe RbCloak::ClientTemplates do
  before(:all) do
    @realm = TestConfig.test_realm('client_templates')
  end

  after(:all) do
    @realm.delete
  end

  let(:manager) { @realm.client_templates }

  let(:entity_name) { 'test_template' }
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

  describe '#update' do
    it 'will update the client\'s template description' do
      new_entity[:description] = 'Test template desc'
      new_entity.update
      entity_read = manager.read(new_entity[:id])
      entity_read[:description].must_equal 'Test template desc'
    end
  end

  describe '#create' do
    it 'will list the client template' do
      new_entity[:name].must_equal entity_name
      manager.find_by_name(entity_name)[:id].must_equal new_entity[:id]
    end

    it 'will create client template' do
      new_entity[:name].must_equal entity_name
    end
  end
end