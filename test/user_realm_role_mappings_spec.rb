# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/user_realm_role_mappings'

describe RbCloak::UserRealmRoleMappings do
  before(:all) do
    @realm, @client = TestConfig.test_client_with_realm('user_realm_role_mappings',
                                                        serviceAccountsEnabled: true,
                                                        standardFlowEnabled:    false)
    @user = @client.service_account
    @realm_mgmt_client = @realm.clients.find_by_client_id('realm-management')
  end

  after(:all) do
    @client.delete
    @realm.delete
  end

  let(:manager) { @user.realm_role_mappings(@realm_mgmt_client['id']) }

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

  describe '#composite' do
    let(:composite_list) { manager.available }
    it 'will list composite mapping for the client' do
      composite_list.must_be_kind_of Array
    end
  end

  describe '#add_mappings' do
    let(:avail_list) { manager.available }
    it 'will update the service account roles' do
      mappings = avail_list.select { |role| role['name'] == 'offline_access' }
      manager.add_mappings(*mappings)
      manager.list.wont_be_empty
    end
  end
end
