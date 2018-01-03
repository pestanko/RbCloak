# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/realm_scope_mappings'

describe RbCloak::ClientRealmScopeMappings do
  before(:all) do
    @realm, @client = TestConfig.test_client_with_realm('client_realm_scope_mappings',
                                                        serviceAccountsEnabled: true,
                                                        standardFlowEnabled:    false)
  end

  after(:all) do
    @client.delete
    @realm.delete
  end

  let(:manager) { @client.realm_scope_mappings }

  let(:entity_name) { 'admin' }

  describe '#list' do
    let(:mappings_list) { manager.list }

    it 'will return an array' do
      mappings_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      mappings_list.must_be_empty
    end
  end

  describe '#available' do
    let(:avail_list) { manager.available }
    it 'will list available mapping for the client' do
      avail_list.must_be_kind_of Array
    end
  end
end