# frozen_string_literal: true

require 'spec_helper'
require 'vault'

describe Hiera::Backend::Vault_backend do
  before do
    stub_hiera
    stub_backend
  end

  it 'fetches kv secret from vault' do
    stub_config(vault: { path: '/some/path' })

    key = 'some-secret'
    scope = {}
    resolution_type = :priority

    backend = described_class.new

    backend.lookup(key, scope, nil, resolution_type, nil)
  end

  it 'uses local credentials' do
    address = 'https://secrets-management-vault-mypulse-management-xenon.mypulse-management.mypulse.technology'
    client = Vault::Client.new(address: address)
    data = client.kv('kv').read('/ci-server/mypulse-management-default/slack_builds_webhook_url').data[:value]

    expect(data).not_to(be_nil)
  end

  def stub_hiera
    allow(Hiera).to(receive(:debug))
  end

  def stub_config(config)
    allow(Hiera::Config).to(receive(:[]).and_return(config))
  end

  def stub_backend
    allow(Hiera::Backend).to(receive(:parse_answer))
  end
end
