# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/realms'

describe RbCloak::Realms do
  let(:url) { TestConfig.url }
  let(:username) { TestConfig.username }
  let(:password) { TestConfig.password }
  let(:client) { TestConfig.client }
  let(:realm) { RbCloak::Realms.new(client) }

  describe '#list' do
    let(:realms_list) { realm.list }

    it 'will return an array' do
      realms_list.must_be_kind_of Array
    end
    it 'will not be an empty array' do
      realms_list.wont_be_empty
    end
  end

  describe '#read' do
    let(:master) { realm.read('master') }

    it 'will find master realm' do
      master.wont_be_nil
    end

    it 'will be a realm' do
      master.must_be_kind_of RbCloak::Realm
    end

    it 'will have name master' do
      master[:realm].must_equal 'master'
    end
  end

  describe '#create' do
    let(:new_realm) do
      realm.read('test_realm')
    end

    before do
      realm.create(
        realm: 'test_realm',
        enabled: 'true'
      )
    end

    after do
      new_realm.delete
    end

    it 'will set a realm name' do
      new_realm['realm'].must_equal 'test_realm'
    end

    it 'will read a realm' do
      test = realm.read('test_realm')
      test[:realm].must_equal 'test_realm'
      test[:enabled].must_equal true
    end
  end

  describe '#update' do
    let(:new_realm) do
      realm.read('test_realm')
    end

    before do
      realm.create(
        realm: 'test_realm'
      )
    end

    after do
      new_realm.delete
    end

    it 'will update enabled' do
      new_realm[:enabled].must_equal false
      new_realm[:enabled] = true
      new_realm.update
      new_realm.read
      new_realm[:enabled].must_equal true
    end
  end
end