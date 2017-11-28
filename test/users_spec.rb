# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/defaults'

describe RbCloak::Realms do
  before(:all) do
    @realm_name = 'test_user_realm'
    @client     = TestConfig.client
    @realms     = RbCloak::Realms.new(@client)
    @realms.create(realm: @realm_name)
    @realm = @realms.read(@realm_name)
  end

  after(:all) do
    @realm.delete
  end

  let(:users) { @realm.users }

  describe '#list' do
    let(:user_list) { users.list }

    it 'will return an array' do
      user_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      user_list.must_be_empty
    end
  end

  describe '#create' do
    let(:username) { 'test_user' }
    let(:new_user) { users.list[0] }

    before do
      users.create(username: username)
    end

    after do
      users.delete(users.list[0][:id])
    end

    it 'will list the user' do
      users.list[0][:username].must_equal username
    end

    it 'will create user' do
      new_user[:username].must_equal username
    end
  end
end