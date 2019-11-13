require 'spec_helper'

describe Hiera::Backend::Vault_backend do
  before(:each) do
    stub_hiera
    stub_vault
    stub_config
  end

  it "logs on initialization" do
    Hiera::Backend::Vault_backend.new

    expect(Hiera)
      .to(have_received(:debug)
                .with('Hiera vault backend starting'))

    expect(Vault::Client)
        .to(have_received(:new)
                .with({address: "123 Park Lane"}))
  end

  it "obtains things from vault" do
    env_backend = Hiera::Backend::Vault_backend.new

    key = 'some_thing'
    vault_secret = 'super-secret'
    processed_value = 'processed-value'
    vault_store = 'test/store'
    scope = {'role' => 'mail_server', 'vault_store' => vault_store}

    secret = instance_double Vault::Secret, data: {some_thing: vault_secret}

    allow(Hiera::Backend)
        .to(receive(:parse_answer)
                .with(vault_secret, scope)
                .and_return(processed_value))
    expect(logical_client)
        .to(receive(:read)
                .with(vault_store)
                .and_return(secret))

    result = env_backend.lookup(key, scope, nil, :priority, nil)

    expect(result).to(equal(processed_value))
  end

  def stub_hiera
    allow(Hiera).to(receive(:debug))
  end

  let(:vault_client) { instance_double Vault::Client, auth_token: auth_token, logical: logical_client }
  let(:auth_token) { instance_double Vault::AuthToken, lookup_self: nil }
  let(:logical_client) { instance_double Vault::Logical, read: nil }

  def stub_vault
    allow(Vault::Client).to(receive(:new).and_return(vault_client))
  end

  def stub_config
    allow(Hiera::Config).to(receive(:[]).and_return({address: "123 Park Lane"}))
  end
end
