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
      realm.read(realm_name).must_be_nil
    end
  end

  describe '#create' do
    # TODO
  end

  describe '#update' do
    # TODO
  end
end