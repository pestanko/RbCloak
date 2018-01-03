# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/client_permissions'

describe RbCloak::ClientPermissions do
  before(:all) do
    @realm, @client = TestConfig.test_client_with_realm('client_permissions')
  end

  after(:all) do
    @client.delete
    @realm.delete
  end

  let(:permissions) { @client.permissions }

  describe '#read' do
    let(:permission) { permissions.read }

    it 'will return an array' do
      permission.must_be_kind_of RbCloak::ClientPermission
    end

    it 'will be an empty array' do
      permission.wont_be_empty
    end
  end

  describe '#update' do
    it 'will update permission' do
      permissions.update(enabled: true)
      result = permissions.read
      result[:enabled].must_equal true
    end

    it 'will enabled manage-clients' do
      permissions.update(enabled: true)
      result = permissions.read
      result[:enabled].must_equal true
    end
  end
end