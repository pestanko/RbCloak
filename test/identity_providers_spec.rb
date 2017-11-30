# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/identity_providers'

describe RbCloak::IdentityProviders do
  before(:all) do
    @realm_name = 'test_provider_realm'
    @client     = TestConfig.client
    @realms     = RbCloak::Realms.new(@client)
    @realms.create(realm: @realm_name)
    @realm = @realms.read(@realm_name)
  end

  after(:all) do
    @realm.delete
  end

  let(:providers) { @realm.identity_providers }
  let(:provider_name) { 'test_provider' }
  let(:new_provider) { providers.find_by_name(provider_name) }

  before do
    providers.create(alias: provider_name)
  end

  after do
    new_provider.delete
  end


  describe '#list' do
    let(:user_list) { providers.list }

    it 'will return an array' do
      user_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      user_list.wont_be_empty
    end
  end

  describe '#read' do
    it 'will list the provider' do
      provider = new_provider
      providers.read(provider[:alias])[:alias].must_equal provider_name
    end
  end

  describe '#update' do
    it 'will update the provider' do
      new_provider[:enabled].must_equal true
      new_provider[:enabled] = false
      new_provider.update
      provider_read = providers.read(new_provider[:alias])
      provider_read[:enabled].must_equal true
    end
  end

  describe '#create' do
    it 'will list the provider' do
      providers.list[0][:alias].must_equal provider_name
    end

    it 'will create provider' do
      new_provider[:alias].must_equal provider_name
    end
  end
end