# frozen_string_literal: true

require 'spec_helper'

describe Hiera::Backend::Vault_backend do
  before do
    Hiera.logger = 'noop'
  end

  it 'logs on initialization' do
    stub_hiera_logging

    described_class.new

    expect(Hiera)
      .to(have_received(:debug)
            .with('Hiera vault backend starting'))
  end

  it 'uses vault address from hiera config' do
    vault_address = 'https://vault.example.com'
    vault_config = {
      address: vault_address
    }
    vault_value = 'some-value'
    vault_secret = create_secret(vault_value)

    key = 'some_thing'
    scope = {}

    stub_hiera_config(vault: vault_config)

    client = instance_double(Vault::Client)
    allow(Vault::Client)
      .to(receive(:new)
            .with(hash_including(address: vault_address))
            .and_return(client))
    allow(client).to(receive(:address=))

    kv = stub_vault_kv_on(client)
    allow(kv).to(receive(:read).and_return(vault_secret))

    vault_backend = described_class.new

    result = vault_backend.lookup(
      key,
      scope,
      nil,
      :priority,
      nil
    )

    expect(result).to(eq(vault_value))
  end

  it 'logs lookup information on lookup' do
    stub_hiera_logging
    stub_hiera_config

    kv = stub_vault_kv

    vault_backend = described_class.new

    key = 'some_thing'
    vault_value = 'unprocessed-value'
    resolution_type = :priority
    scope = {}

    secret = create_secret(vault_value)

    allow(kv).to(receive(:read).and_return(secret))

    vault_backend.lookup(
      key,
      scope,
      nil,
      resolution_type,
      nil
    )

    expect(Hiera)
      .to(have_received(:debug)
            .with("Looking up #{key} in vault backend " \
                  "with #{resolution_type}"))
  end

  it 'reads the value from vault' do
    stub_hiera_config

    kv = stub_vault_kv

    vault_backend = described_class.new

    key = 'some_thing'
    vault_value = 'unprocessed-value'
    scope = {}

    secret = create_secret(vault_value)

    allow(kv).to(receive(:read).and_return(secret))

    result = vault_backend.lookup(
      key,
      scope,
      nil,
      :priority,
      nil
    )

    expect(result).to(eq(vault_value))
  end

  it 'returns the recursively parsed value after lookup' do
    stub_hiera_config

    kv = stub_vault_kv

    vault_backend = described_class.new

    key = 'some_thing'
    vault_value = 'unprocessed-value'
    processed_value = 'processed-value'
    scope = {}

    allow(Hiera::Backend)
      .to(receive(:parse_answer)
            .with(vault_value, scope)
            .and_return(processed_value))

    secret = create_secret(vault_value)

    allow(kv).to(receive(:read).and_return(secret))

    result = vault_backend.lookup(
      key,
      scope,
      nil,
      :priority,
      nil
    )

    expect(result).to(eq(processed_value))
  end

  it 'throws if the secret cannot be resolved' do
    stub_hiera_config

    kv = stub_vault_kv

    vault_backend = described_class.new

    key = 'some_thing'
    scope = {}

    allow(kv).to(receive(:read).and_return(nil))

    expect do
      vault_backend.lookup(
        key,
        scope,
        nil,
        :priority,
        nil
      )
    end.to(throw_symbol(:no_such_key))
  end

  it 'throws if the secret is missing value' do
    stub_hiera_config

    kv = stub_vault_kv

    vault_backend = described_class.new

    key = 'some_thing'
    scope = {}
    secret = create_secret(nil)

    allow(kv).to(receive(:read).and_return(secret))

    expect do
      vault_backend.lookup(
        key,
        scope,
        nil,
        :priority,
        nil
      )
    end.to(throw_symbol(:no_such_key))
  end

  def stub_hiera_logging
    allow(Hiera).to(receive(:debug))
  end

  def stub_hiera_config(
    config = { vault: { address: 'https://vault.example.com' } }
  )
    allow(Hiera::Config).to(receive(:[]) { |key| config[key] })
    allow(Hiera::Backend).to(receive(:parse_answer).and_call_original)
  end

  def stub_vault_client
    client = instance_double(Vault::Client)
    allow(Vault::Client).to(receive(:new).and_return(client))
    client
  end

  def stub_vault_kv_on(client)
    kv = instance_double(Vault::KV)
    allow(kv).to(receive(:read))
    allow(client).to(receive(:kv).and_return(kv))
    kv
  end

  def stub_vault_kv
    stub_vault_kv_on(stub_vault_client)
  end

  def create_secret(value)
    Vault::Secret.new({ data: { value: value } })
  end
end
