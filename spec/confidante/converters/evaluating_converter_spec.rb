# frozen_string_literal: true

require 'spec_helper'

describe Confidante::Converters::EvaluatingConverter do
  it 'returns integer values unchanged' do
    expect(described_class.new.convert(10)).to(eq(10))
  end

  it 'returns nil values unchanged' do
    expect(described_class.new.convert(nil)).to(be_nil)
  end

  it 'returns symbol values unchanged' do
    expect(described_class.new.convert(:symbol)).to(eq(:symbol))
  end

  it 'returns boolean values unchanged' do
    expect(described_class.new.convert(true)).to(be(true))
  end

  it 'returns strings that do not look evaluable unchanged' do
    expect(described_class.new.convert('plain value')).to(eq('plain value'))
  end

  it 'evaluates strings that look like serialised arrays' do
    expect(described_class.new.convert('[1, 2, 3]')).to(eq([1, 2, 3]))
  end

  it 'evaluates strings that look like serialised hashes' do
    expect(described_class.new.convert('{ a: 1 }')).to(eq({ a: 1 }))
  end

  it 'returns evaluable-looking strings unchanged when evaluation raises' do
    expect(described_class.new.convert('[1].nonexistent_method'))
      .to(eq('[1].nonexistent_method'))
  end

  it 'recursively converts values within hashes' do
    expect(described_class.new.convert({ 'key' => '[1, 2]' }))
      .to(eq({ key: [1, 2] }))
  end

  it 'recursively converts values within arrays' do
    expect(described_class.new.convert(['[1, 2]', 10]))
      .to(eq([[1, 2], 10]))
  end
end
