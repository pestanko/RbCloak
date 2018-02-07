# frozen_string_literal: true

require_relative '../test_helper'

describe 'RbCloak::Cli::Realms' do
  let(:client) { TestConfig.client }
  let(:realm) { client.realms }

  describe '#list' do
    let(:realms_list) { TestConfig.cli('realms list') }

    it 'will return an array' do
      realms_list.include? 'master'
    end
  end

  describe '#read' do
    let(:master) { realm.read('master') }
    let(:master_read) { TestConfig.cli('realms read master') }

    it 'will find master realm' do
      parsed = JSON.parse(master_read)
      parsed['realm'].must_equal master[:realm]
      parsed['realm'].must_equal 'master'
    end
  end

  describe '#delete' do
    let(:realm_name) { 'test_realm_to_delete' }
    let(:new_realm) do
      realm.create(
        realm: realm_name,
        enabled: true
      )
      realm.read('test_realm_to_delete')
    end

    it 'will delete a realm' do
      TestConfig.cli("realms delete -v #{new_realm[:realm]}")
      deleted_realm = realm.read(realm_name)
      deleted_realm.must_be_nil
    end
  end

  describe '#create' do
    before do
      command = "#{TestConfig.binary_path} realms create"
      IO.popen(command, 'r+') do |io|
        io.write '{ "realm": "test_realm_by_cli" }'
        io.close_write
      end
    end

    let(:created_realm) do
      realm.read('test_realm_by_cli')
    end

    it 'will create realm' do
      created_realm[:realm].must_equal 'test_realm_by_cli'
    end

    after do
      created_realm.delete
    end
  end

  describe '#update' do
    let(:realm_name) { 'test_updated_realm_cli' }
    before do
      realm.create(
        realm: realm_name,
        enabled: 'false'
      )
      updated
    end

    after do
      updated_realm.delete
    end

    let(:updated) do
      command = "#{TestConfig.binary_path} realms update #{realm_name}"
      IO.popen(command, 'r+') do |io|
        io.write '{ "enabled": true }'
        io.close_write
      end
    end

    let(:updated_realm) do
      realm.read('test_updated_realm_cli')
    end

    it 'will be updated' do
      updated_realm[:enabled].must_equal true
    end
  end
end
