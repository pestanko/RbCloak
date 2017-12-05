# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/client_roles'

describe RbCloak::ClientRoles do
  before(:all) do
    @realm_name = 'test_client_role_realm'
    @client     = TestConfig.client
    @realms     = RbCloak::Realms.new(@client)
    @realms.create(realm: @realm_name)
    @realm = @realms.read(@realm_name)
    @realm.clients.create(name: 'test_client')
    @client = @realm.clients.find_by_name('test_client')
  end

  after(:all) do
    @client.delete
    @realm.delete
  end
  let(:roles) { @client.roles }

  let(:role_name) { 'test_role' }
  let(:new_role) { roles.read(role_name) }

  before do
    roles.create(name: role_name)
  end

  after do
    new_role.delete
  end


  describe '#list' do
    let(:roles_list) { roles.list }

    it 'will return an array' do
      roles_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      roles_list.wont_be_empty
    end
  end

  describe '#read' do
    it 'will read the role' do
      roles.read(new_role[:name])[:id].must_equal new_role[:id]
    end
  end

  describe '#update' do
    it 'will update the role' do
      new_role[:description] = 'Some desc'
      new_role.update
      roles.read(role_name)[:description].must_equal 'Some desc'
    end
  end

  describe '#create' do
    it 'will create the role' do
      new_role[:name].must_equal role_name
    end
  end
end