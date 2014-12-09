# encoding: UTF-8

require 'spec_helper'

include Rosette::Serializers

describe YamlSerializer::RailsSerializer do
  let(:stream) { StringIO.new }
  let(:locale) { Rosette::Core::Locale.parse('fr-FR') }
  let(:serializer) do
    YamlSerializer::RailsSerializer.new(
      stream, locale
    )
  end

  it 'writes key/value pairs' do
    serializer.write_key_value('foo', 'bar')
    serializer.flush
    result = YAML.load(stream.string)
    expect(result).to eq('fr' => { 'foo' => 'bar' })
  end

  it 'nests dotted keys' do
    serializer.write_key_value('foo.bar.baz', 'boo')
    serializer.flush
    result = YAML.load(stream.string)
    expect(result).to eq({
      'fr' => { 'foo' => { 'bar' => { 'baz' => 'boo' } } }
    })
  end

  it 'writes multiple key/value pairs independent of order' do
    serializer.write_key_value('i.like.burritos', 'beanz')
    serializer.write_key_value('ham.cheese', 'sandwich')
    serializer.write_key_value('i.like.cheesy.burritos', 'yum')
    serializer.write_key_value('ham.lettuce', 'crunchay')
    serializer.flush
    result = YAML.load(stream.string)

    expect(result).to eq({
      'fr' => {
        'i' => {
          'like' => {
            'burritos' => 'beanz',
            'cheesy' => {
              'burritos' => 'yum'
            }
          }
        },
        'ham' => {
          'cheese' => 'sandwich',
          'lettuce' => 'crunchay'
        }
      }
    })
  end

  it 'writes arrays for sequential keys' do
    serializer.write_key_value('foo.1', 'b')
    serializer.write_key_value('foo.0', 'a')
    serializer.write_key_value('foo.2', 'c')
    serializer.flush
    result = YAML.load(stream.string)

    expect(result).to eq({
      'fr' => { 'foo' => ['a', 'b', 'c'] }
    })
  end

  it 'does not write arrays for sequential but non-numeric keys' do
    serializer.write_key_value('foo.bar1', 'b')
    serializer.write_key_value('foo.bar0', 'a')
    serializer.write_key_value('foo.bar2', 'c')
    serializer.flush
    result = YAML.load(stream.string)

    expect(result).to eq({
      'fr' => {
        'foo' => {
          'bar1' => 'b',
          'bar0' => 'a',
          'bar2' => 'c'
        }
      }
    })
  end

  it 'writes nested key/value pairs and arrays (in any order)' do
    serializer.write_key_value('foo.0.bar.0', 'a')
    serializer.write_key_value('foo.0.bar.1', 'b')
    serializer.write_key_value('foo.1.bar.0', 'c')
    serializer.write_key_value('foo.1.bar.1', 'd')
    serializer.flush
    result = YAML.load(stream.string)

    expect(result).to eq({
      'fr' => {
        'foo' => [
          { 'bar' => ['a', 'b'] },
          { 'bar' => ['c', 'd'] }
        ]
      }
    })
  end
end
