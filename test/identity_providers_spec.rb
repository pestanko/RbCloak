# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/identity_providers'

describe RbCloak::IdentityProviders do
  before(:all) do
    @realm = TestConfig.test_realm('identity')
  end

  after(:all) do
    @realm.delete
  end

  let(:manager) { @realm.identity_providers }
  let(:entity_name) { 'test_provider' }
  let(:new_entity) { manager.find_by_name(entity_name) }

  before do
    manager.create(alias: entity_name)
  end

  after do
    new_entity.delete
  end


  describe '#list' do
    let(:user_list) { manager.list }

    it 'will return an array' do
      user_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      user_list.wont_be_empty
    end
  end

  describe '#read' do
    it 'will list the provider' do
      provider = new_entity
      manager.read(provider[:alias])[:alias].must_equal entity_name
    end
  end

  describe '#update' do
    it 'will update the provider' do
      new_entity[:enabled].must_equal true
      new_entity[:enabled] = false
      new_entity.update
      provider_read = manager.read(new_entity[:alias])
      provider_read[:enabled].must_equal true
    end
  end

  describe '#create' do
    it 'will list the provider' do
      manager.list[0][:alias].must_equal entity_name
    end

    it 'will create provider' do
      new_entity[:alias].must_equal entity_name
    end
  end
end