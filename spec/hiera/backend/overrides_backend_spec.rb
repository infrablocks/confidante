# frozen_string_literal: true

require 'spec_helper'

describe Hiera::Backend::Overrides_backend do
  before do
    stub_hiera
    stub_backend
  end

  it 'logs on initialization' do
    described_class.new

    expect(Hiera)
      .to(have_received(:debug)
                .with('Hiera overrides backend starting'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'logs on lookup' do
    overrides_backend = described_class.new

    key = 'some_thing'
    scope = { 'role' => 'mail_server',
              'overrides' => { 'some_thing' => 'value' } }
    resolution_type = :priority

    overrides_backend.lookup(
      key,
      scope,
      nil,
      resolution_type,
      nil
    )

    expect(Hiera)
      .to(have_received(:debug)
                .with("Looking up #{key} in overrides backend " \
                        "with #{resolution_type}"))
    expect(Hiera)
      .to(have_received(:debug)
                .with("Found overrides: #{scope['overrides']}"))
    expect(Hiera)
      .to(have_received(:debug)
                .with("Found override: #{scope['overrides']['some_thing']} " \
                        "for key: #{key}"))
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'returns the value from the overrides key in scope after parsing with ' \
     'other backends' do
    overrides_backend = described_class.new

    key = 'some_thing'
    overrides_value = 'unprocessed-value'
    processed_value = 'processed-value'
    scope = {
      'role' => 'mail_server',
      'overrides' => {
        'some_thing' => overrides_value
      }
    }

    allow(Hiera::Backend)
      .to(receive(:parse_answer)
                .with(overrides_value, scope)
                .and_return(processed_value))

    result = overrides_backend.lookup(
      key,
      scope,
      nil,
      :priority,
      nil
    )

    expect(result).to(equal(processed_value))
  end

  it 'throws if the key cannot be resolved' do
    overrides_backend = described_class.new

    key = 'some_thing'
    scope = {
      'role' => 'mail_server',
      'overrides' => {}
    }

    expect do
      overrides_backend.lookup(
        key,
        scope,
        nil,
        :priority,
        nil
      )
    end.to(throw_symbol(:no_such_key))
  end

  it 'throws if no overrides are available' do
    overrides_backend = described_class.new

    key = 'some_thing'
    scope = {
      'role' => 'mail_server'
    }

    expect do
      overrides_backend.lookup(
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

  def stub_backend
    allow(Hiera::Backend).to(receive(:parse_answer))
  end
end
