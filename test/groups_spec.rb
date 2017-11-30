# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/groups'

describe RbCloak::Groups do
  before(:all) do
    @realm_name = 'test_group_realm'
    @client     = TestConfig.client
    @realms     = RbCloak::Realms.new(@client)
    @realms.create(realm: @realm_name)
    @realm = @realms.read(@realm_name)
  end

  after(:all) do
    @realm.delete
  end

  let(:groups) { @realm.groups }

  let(:group_name) { 'test_group' }
  let(:new_group) { groups.find_by_name(group_name) }

  before do
    groups.create(name: group_name)
  end

  after do
    groups.delete(groups.find_by_name(group_name)[:id])
  end

  describe '#list' do
    let(:client_list) { groups.list }

    it 'will return an array' do
      client_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      list = client_list
      list.wont_be_empty
    end
  end

  describe '#read' do
    it 'will list the group' do
      groups.read(new_group[:id])[:name].must_equal group_name
    end
  end

  describe '#create' do
    it 'will list the client' do
      new_group[:name].must_equal group_name
      groups.find_by_name(group_name)[:id].must_equal new_group[:id]
    end

    it 'will create client' do
      new_group[:name].must_equal group_name
    end
  end
end