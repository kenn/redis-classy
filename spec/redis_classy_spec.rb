require 'spec_helper'

class Something < RedisClassy
end

describe RedisClassy do
  before do
    RedisClassy.redis.flushdb
  end

  after(:all) do
    RedisClassy.redis.flushdb
    RedisClassy.redis.quit
  end

  it 'raises RedisClassy::Error when connection is missing' do
    begin
      backup = RedisClassy.redis
      RedisClassy.redis = nil

      class NoConnection < RedisClassy
      end

      expect{ NoConnection.keys }.to raise_error(RedisClassy::Error)
    ensure
      RedisClassy.redis = backup
    end
  end

  it 'stores redis or redis-namespace' do
    expect(RedisClassy.redis.is_a?(Redis)).to be_truthy
    expect(RedisClassy.redis.is_a?(Redis::Namespace)).to be_falsy
    expect(Something.redis.is_a?(Redis)).to be_falsy
    expect(Something.redis.is_a?(Redis::Namespace)).to be_truthy
  end

  it 'gets keys' do
    Something.on(:foo).set('bar')
    expect(Something.keys).to eq(['foo'])
    expect(RedisClassy.keys).to eq(['Something:foo'])
  end

  it 'prepends class name to the key' do
    class Another < Something
    end

    module Deep
      class Klass < Another
      end
    end

    Something.on(:foo).set('bar')
    expect(Something.on(:foo).keys).to eq(['foo'])
    expect(RedisClassy.keys.size).to eq(1)
    expect(RedisClassy.keys).to include 'Something:foo'

    Another.on(:foo).set('bar')
    expect(Another.on(:foo).keys).to eq(['foo'])
    expect(RedisClassy.keys.size).to eq(2)
    expect(RedisClassy.keys).to include 'Another:foo'

    Deep::Klass.on(:foo).set('bar')
    expect(Deep::Klass.on(:foo).keys).to eq(['foo'])
    expect(RedisClassy.keys.size).to eq(3)
    expect(RedisClassy.keys).to include 'Deep::Klass:foo'
  end

  it 'delegates instance methods with the key binding' do
    something = Something.new('foo')

    expect(something.get).to eq(nil)
    something.set('bar')
    expect(something.get).to eq('bar')
    expect(Something.on(:foo).get).to eq('bar')
  end

  it 'handles multi block' do
    something = Something.new('foo')

    something.multi do
      something.sadd 1
      something.sadd 2
      something.sadd 3
    end

    expect(something.smembers).to eq(['1','2','3'])
  end

  it 'handles watch' do
    something = Something.new('foo')

    something.watch do
      something.unwatch
    end
  end

  it 'handles method_missing' do
    # class method
    expect { Something.bogus }.to raise_error(NoMethodError)

    # instance method
    something = Something.new('foo')
    expect { something.bogus }.to raise_error(NoMethodError)
  end

  it 'handles singleton key' do
    class Counter < RedisClassy
      singleton
    end

    Counter.incr
    expect(Counter.get).to eq('1')
    Counter.incr
    expect(Counter.get).to eq('2')
  end

  it 'handles predefined keys' do
    class Stats < RedisClassy
      singletons :median, :average
    end

    ages = [21,22,24,28,30]
    Stats.median.set  ages[ages.size/2]
    Stats.average.set ages.inject(:+)/ages.size
    expect(Stats.median.get).to eq('24')
    expect(Stats.average.get).to eq('25')
    expect([:average, :median] - Stats.keys.map(&:to_sym)).to eq([])
    expect(Stats.singletons_keys).to eq([:median, :average])
  end

  it 'handles multiple key commands' do
    Something.mset :a, 1, :b, 2
    expect(Something.mget(:a, :b)).to eq(['1', '2'])
    expect(Something.mapped_mget(:a, :b)).to eq({'a' => '1', 'b' => '2'})
  end

  it 'allows conditional assignment' do
    RedisClassy.redis = nil
    expect {
      RedisClassy.redis ||= Redis.new(db: 15)
    }.to_not raise_error
  end
end
