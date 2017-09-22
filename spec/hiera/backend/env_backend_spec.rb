require 'spec_helper'

describe Hiera::Backend::Env_backend do
  before(:each) do
    stub_hiera
    stub_backend
    stub_env
  end

  it 'logs on initialization' do
    Hiera::Backend::Env_backend.new

    expect(Hiera)
        .to(have_received(:debug)
                .with('Hiera environment backend starting'))

  end

  it 'logs on lookup' do
    env_backend = Hiera::Backend::Env_backend.new

    key = 'some_thing'
    scope = {role: 'mail_server'}
    resolution_type = :priority

    env_backend.lookup(key, scope, nil, resolution_type, nil)

    expect(Hiera)
        .to(have_received(:debug)
                .with("Looking up #{key} in environment backend with #{resolution_type}"))
  end

  it 'returns the value from the environment variable after parsing with other backends' do
    env_backend = Hiera::Backend::Env_backend.new

    key = 'some_thing'
    env_value = 'unprocessed-value'
    processed_value = 'processed-value'
    scope = {role: 'mail_server'}

    allow(ENV)
        .to(receive(:[])
                .with('SOME_THING')
                .and_return(env_value))
    allow(Hiera::Backend)
        .to(receive(:parse_answer)
                .with(env_value, scope)
                .and_return(processed_value))

    result = env_backend.lookup(key, scope, nil, :priority, nil)

    expect(result).to(equal(processed_value))
  end

  it 'throws if the key cannot be resolved' do
    env_backend = Hiera::Backend::Env_backend.new

    key = 'some_thing'
    scope = {role: 'mail_server'}

    allow(ENV)
        .to(receive(:[])
                .with('SOME_THING')
                .and_return(nil))

    expect {
      env_backend.lookup(key, scope, nil, :priority, nil)
    }.to(throw_symbol(:no_such_key))
  end

  def stub_hiera
    allow(Hiera).to(receive(:debug))
  end

  def stub_backend
    allow(Hiera::Backend).to(receive(:parse_answer))
  end

  def stub_env
    allow(ENV).to(receive(:[]).and_return('value'))
  end
end