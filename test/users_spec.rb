# frozen_string_literal: true

require_relative 'test_helper'

require 'rb_cloak/users'

describe RbCloak::Users do
  before(:all) do
    @realm = TestConfig.test_realm('users')
  end

  after(:all) do
    @realm.delete
  end

  let(:manager) { @realm.users }
  let(:entity_name) { 'test_user' }
  let(:new_entity) { manager.list[0] }

  before do
    manager.create(username: entity_name)
  end

  after do
    manager.delete(manager.list[0][:id])
  end


  describe '#list' do
    let(:user_list) { manager.list }

    it 'will return an array' do
      user_list.must_be_kind_of Array
    end

    it 'will be an empty array' do
      user_list.wont_be_empty
    end
  end

  describe '#read' do
    it 'will list the user' do
      manager.read(new_entity[:id])[:username].must_equal entity_name
    end
  end

  describe '#update' do
    it 'will update the user' do
      email = "#{entity_name}@example.com"
      new_entity[:email] = email
      new_entity.update
      manager.read(new_entity[:id])[:email].must_equal email
    end
  end

  describe '#create' do
    it 'will list the user' do
      manager.list[0][:username].must_equal entity_name
    end

    it 'will create user' do
      new_entity[:username].must_equal entity_name
    end
  end

  describe '#set password' do
    it 'will set password' do
      new_entity.password('123456').wont_be_nil
    end
  end
end