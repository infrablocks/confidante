# frozen_string_literal: true

require 'spec_helper'

describe Hiera::Backend::Vault_backend do
  before do
    stub_hiera
    stub_backend
  end

  it 'fetches kv secret from vault' do
    stub_config(vault: {path: '/some/path'})

    key = 'some-secret'
    scope = {}
    resolution_type = :priority

    backend = described_class.new

    backend.lookup(key, scope, nil, resolution_type, nil)
    
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
