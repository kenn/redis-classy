# Redis Classy

[![Build Status](https://secure.travis-ci.org/kenn/redis-classy.png)](http://travis-ci.org/kenn/redis-classy)

A very simple, class-based namespace prefixing and encapsulation for Redis. Key features include:

- Establishes a maintainable convention by prefixing keys with the class name (e.g. `YourClass:123`)
- Delegates all method calls to the [redis-rb](https://github.com/redis/redis-rb) within the namespace
- Adds a better abstraction layer around Redis objects and commands

Here's an example:

```ruby
class Timer < RedisClassy
  def start
    pipelined do
      set Time.now.to_i
      expire 120.seconds
    end
  end

  def stop
    del
  end

  def running?
    !!get
  end
end

timer = Timer.new(123)
timer.start
timer.running?
=> true

Timer.keys
=> ["123"]
RedisClassy.keys
=> ["Timer:123"]
```

The Timer class above is self-contained and more readable.

This library is made intentionally small, yet powerful when you need better abstraction on Redis objects to keep things organized.

### UPGRADING FROM v1

[**An important message about upgrading from 1.x**](UPGRADING.md)


## redis-rb vs redis-namespace vs redis-classy

With the vanilla `redis` gem, you've been doing this:

```ruby
redis = Redis.new
redis.set 'foo', 'bar'
redis.get 'foo'                 # => "bar"
```

With the `redis-namespace` gem, you can add a prefix in the following manner:

```ruby
redis_ns = Redis::Namespace.new('ns', :redis => redis)
redis_ns['foo'] = 'bar'         # equivalent of => redis.set 'ns:foo', 'bar'
redis_ns['foo']                 # => "bar"
```

Now, with the `redis-classy` gem, you finally achieve a class-based naming convention:

```ruby
class Something < RedisClassy
end

Something.on('foo').set('bar')  # equivalent of => redis.set 'Something:foo', 'bar'
Something.on('foo').get         # => "bar"

something = Something.new('foo')
something.set 'bar'             # equivalent of => redis.set 'Something:foo', 'bar'
something.get                   # => "bar"
```

Usage
-----

In Gemfile:

```ruby
gem 'redis-classy'
```

Register the Redis server: (e.g. in `config/initializers/redis_classy.rb` for Rails)

```ruby
RedisClassy.redis = Redis.current
```

Create a class that inherits RedisClassy. (e.g. in `app/redis/cache.rb` for Rails, for auto- and eager-loading)

```ruby
class Cache < RedisClassy
  def put(content)
    pipelined do
      set content
      expire 5.seconds
    end
  end
end

cache = Cache.new(123)
cache.put "This tape will self-destruct in five seconds. Good luck."
```

Since the `on` method is added as a syntactic sugar for `new`, you can also run a command in one shot as well:

```ruby
Cache.on(123).persist
```

For convenience, singleton and predefined static keys are also supported.

```ruby
class Counter < RedisClassy
  singleton
end

Counter.incr    # 'Counter:singleton' => '1'
Counter.incr    # 'Counter:singleton' => '2'
Counter.get     # => '2'
```

``` ruby
class Stats < RedisClassy
  singletons :median, :average
end

ages = [21,22,24,28,30]

Stats.median.set  ages[ages.size/2]           # 'Stats:median'  => '24'
Stats.average.set ages.inject(:+)/ages.size   # 'Stats:average' => '25'
Stats.median.get    # => '24'
Stats.average.get   # => '25'
```

Finally, you can also pass an arbitrary object that responds to `id` as a key. This is useful when used in combination with ActiveRecord, etc.

```ruby
class Lock < RedisClassy
end

class Room < ActiveRecord::Base
end

room = Room.create

lock = Lock.new(room)
```

When you need an access to the non-namespaced, raw Redis keys, it's available as `RedisClass.keys`. Keep in mind that this method is very slow at O(N) computational complexity and potentially hazardous when you have many keys. [Read the details](http://redis.io/commands/keys).

```ruby
RedisClassy.keys
=> ["Stats:median", "Stats:average", "Counter"]

RedisClassy.keys 'Stats:*'
=> ["Stats:median", "Stats:average"]
```

Since the `redis` attribute is a class instance variable, you can dynamically assign different databases for each class, without affecting other classes.

```ruby
Cache.redis = Redis::Namespace.new('Cache', redis: Redis.new(host: 'another.host'))
```

Unicorn support
---------------

If you run fork-based app servers such as **Unicorn** or **Passenger**, you need to reconnect to the Redis after forking.

```ruby
after_fork do
  RedisClassy.redis.client.reconnect
end
```

Note that since Redis Classy assigns a namespaced Redis instance upon the inheritance event of each subclass (`class Something < RedisClassy`), reconnecting the master (non-namespaced) connection that is referenced from all subclasses should probably be the safest and the most efficient way to survive a forking event.

Reference
---------

Dependency:

* <https://github.com/ezmobius/redis-rb>
* <https://github.com/defunkt/redis-namespace>

Use case:

* <https://github.com/kenn/redis-mutex>
