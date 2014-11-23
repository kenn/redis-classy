require 'spec_helper'

class Something < Redis::Classy
end

class Another < Something
end

module Deep
  class Klass < Another
  end
end

describe Redis::Classy do
  before do
    Redis::Classy.flushdb
  end

  after(:all) do
    Redis::Classy.flushdb
    Redis::Classy.quit
  end

  it 'prepends class name to the key' do
    Something.set('foo', 'bar')
    expect(Something.keys).to eq(['foo'])
    expect(Redis::Classy.keys).to include 'Something:foo'

    Another.set('foo', 'bar')
    expect(Another.keys).to eq(['foo'])
    expect(Redis::Classy.keys).to include 'Another:foo'

    Deep::Klass.set('foo', 'bar')
    expect(Deep::Klass.keys).to eq(['foo'])
    expect(Redis::Classy.keys).to include 'Deep::Klass:foo'
  end

  it 'delegates to class methods' do
    expect(Something.get('foo')).to eq(nil)
    Something.set('foo', 'bar')
    expect(Something.get('foo')).to eq('bar')
  end

  it 'delegates instance methods with the key binding' do
    something = Something.new('foo')

    expect(something.get).to eq(nil)
    something.set('bar')
    expect(something.get).to eq('bar')
    expect(Something.get('foo')).to eq('bar')
  end

  it 'handles multi block' do
    something = Something.new('foo')

    Redis::Classy.multi do
      something.sadd 1
      something.sadd 2
      something.sadd 3
    end

    expect(something.smembers).to eq(['1','2','3'])
  end

  it 'handles method_missing' do
    # class method
    expect { Something.bogus }.to raise_error(NoMethodError)

    # instance method
    something = Something.new('foo')
    expect { something.bogus }.to raise_error(NoMethodError)
  end

  it 'should battle against mongoid' do
    # Emulate notorious Mongoid::Extensions::Object::Conversions
    class Object
      def self.get(value)
        value
      end
    end

    # This would have returned "foo" instead of nil, unless we explicitly defined
    # class methods from Redis::Namespace::COMMANDS
    expect(Something.get('foo')).to eq(nil)

    class << Object
      remove_method :get
    end
  end
end
