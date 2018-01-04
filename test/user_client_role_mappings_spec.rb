# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/user_client_scope_mappings'

describe RbCloak::UserClientRoleMapping do
  before(:all) do
    @realm, @client = TestConfig.test_client_with_realm('user_client_role_mapping',
                                                        serviceAccountsEnabled: true,
                                                        standardFlowEnabled:    false)
    @user = @client.service_account
    @realm_mgmt_client = @realm.clients.find_by_client_id('realm-management')
  end

  after(:all) do
    @client.delete
    @realm.delete
  end

  let(:manager) { @user.client_role_mappings(@realm_mgmt_client['id']) }

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

    it 'will contain create client role' do
      create_client = avail_list.select { |role| role['name'] == 'create-client' }[0]
      create_client.wont_be_nil
      create_client['name'].must_equal 'create-client'
    end
  end

  describe '#composite' do
    let(:composite_list) { manager.available }
    it 'will list composite mapping for the client' do
      composite_list.must_be_kind_of Array
    end
  end

  describe '#add_mappings' do
    let(:avail_list) { manager.available }
    it 'will update the service account roles' do
      mappings = avail_list.select { |role| role['name'] == 'create-client' }
      manager.add_mappings(*mappings)
      manager.list.wont_be_empty
    end
  end
end