require 'spec_helper'

describe Confidante::Configuration do
  it 'delegates to the supplied hiera instance with scope containing supplied overrides and scope' do
    hiera = double
    expected_value = 10

    allow(hiera).to(receive(:lookup).and_return(expected_value))

    configuration = Confidante::Configuration.new(hiera: hiera)
                        .for_overrides(
                            thing1: 'value1',
                            thing2: 'value2')
                        .for_scope(
                            role: 'server',
                            environment: 'production')

    actual_value = configuration.some_important_value

    expect(actual_value).to(equal(expected_value))
    expect(hiera)
        .to(have_received(:lookup)
                .with(
                    'some_important_value',
                    nil,
                    {
                        'cwd' => Dir.pwd,
                        'role' => 'server',
                        'environment' => 'production',
                        'overrides' => {
                            'thing1' => 'value1',
                            'thing2' => 'value2'
                        }
                    }))
  end

  it 'defaults to having no overrides when none specified' do
    hiera = double
    expected_value = 10

    allow(hiera).to(receive(:lookup).and_return(expected_value))

    configuration = Confidante::Configuration.new(hiera: hiera)
                        .for_scope(
                            role: 'server',
                            environment: 'production')

    actual_value = configuration.some_important_value

    expect(actual_value).to(equal(expected_value))
    expect(hiera)
        .to(have_received(:lookup)
                .with(
                    'some_important_value',
                    nil,
                    {
                        'cwd' => Dir.pwd,
                        'role' => 'server',
                        'environment' => 'production',
                        'overrides' => {}
                    }))
  end

  it 'defaults to having an empty scope when none specified' do
    hiera = double
    expected_value = 10

    allow(hiera).to(receive(:lookup).and_return(expected_value))

    configuration = Confidante::Configuration.new(hiera: hiera)
                        .for_overrides(
                            thing1: 'value1',
                            thing2: 'value2')

    actual_value = configuration.some_important_value

    expect(actual_value).to(equal(expected_value))
    expect(hiera)
        .to(have_received(:lookup)
                .with(
                    'some_important_value',
                    nil,
                    {
                        'cwd' => Dir.pwd,
                        'overrides' => {
                            'thing1' => 'value1',
                            'thing2' => 'value2'
                        }
                    }))
  end

  it 'converts overrides to a hash using to_hash when supported' do
    expected_value = 'value'

    hiera = double
    overrides = double
    overrides_hash = {some_important_value: expected_value}

    allow(hiera).to(receive(:lookup).and_return(expected_value))
    allow(overrides)
        .to(receive(:to_h)
                .and_return(overrides_hash))

    configuration = Confidante::Configuration.new(hiera: hiera)
                        .for_overrides(overrides)

    actual_value = configuration.some_important_value

    expect(actual_value).to(equal(expected_value))
    expect(hiera)
        .to(have_received(:lookup)
                .with(
                    'some_important_value',
                    nil,
                    {
                        'cwd' => Dir.pwd,
                        'overrides' => {
                            'some_important_value' => expected_value
                        }
                    }))
  end

  it 'applies converters to looked up values when provided' do
    lookup_value = {
        key: "[{:key1 => \"value1\", :key2 => \"value2\"}]",
        nested: {
          key: "[{:key1 => \"value1\", :key2 => \"value2\"}]",
        },
        embedded: ["{:key1 => \"value1\"}", "{:key2 => \"value2\"}"]
    }
    expected_value = {
        key: [{:key1 => "value1", :key2 => "value2"}],
        nested: {
            key: [{:key1 => "value1", :key2 => "value2"}]
        },
        embedded: [{:key1 => "value1"}, {:key2 => "value2"}]
    }

    hiera = double

    allow(hiera).to(receive(:lookup).and_return(lookup_value))

    configuration = Confidante::Configuration.new(
        hiera: hiera,
        converters: [Confidante::Converters::EvaluatingConverter.new]
    )

    actual_value = configuration.some_value

    expect(actual_value).to(eq(expected_value))
  end
end
