# frozen_string_literal: true

require 'spec_helper'

describe Hiera::Backend::Vault_backend do
  before do
    Hiera.logger = 'noop'
  end

  it 'logs on initialization' do
    stub_hiera

    described_class.new

    expect(Hiera)
      .to(have_received(:debug)
                .with('Hiera vault backend starting'))
  end

  it 'logs lookup information on lookup' do
    stub_hiera
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

  it 'returns the value from vault-ruby' do
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

  def stub_hiera
    allow(Hiera).to(receive(:debug))
  end

  def stub_vault_kv
    client = instance_double(Vault::Client)
    allow(Vault::Client).to(receive(:new).and_return(client))
    kv = instance_double(Vault::KV)
    allow(kv).to(receive(:read))
    allow(client).to(receive(:kv).and_return(kv))
    kv
  end

  def create_secret(value)
    Vault::Secret.new({ data: { value: value } })
  end
end
