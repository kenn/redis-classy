Redis Classy
============

[![Build Status](https://secure.travis-ci.org/kenn/redis-classy.png)](http://travis-ci.org/kenn/redis-classy)

Class-style namespace prefixing for Redis.

With Redis Classy, class names become the prefix part of the Redis keys.

```ruby
class Something < RedisClassy
end

Something.on('foo').set('bar')      # equivalent of => redis.set 'Something:foo', 'bar'
Something.on('foo').get             # equivalent of => redis.get 'Something:foo'
 => "bar"
```

```ruby
class Counter < RedisClassy
  singleton
end

Counter.incr    # 'Counter:singleton' => '1'
Counter.incr    # 'Counter:singleton' => '2'
Counter.get
 => '2'
```

``` ruby
class Stats < RedisClassy
  singletons :median, :average
end

ages = [21,22,24,28,30]
Stats.median.set  ages[ages.size/2]           # 'Stats:median'  => '24'
Stats.average.set ages.inject(:+)/ages.size   # 'Stats:average' => '25'
Stats.median.get
 => '24'
Stats.average.get
 => '25'
```

All methods are delegated to the `redis-namespace` gems.

This library is made intentionally small, yet powerful when you need better abstraction on Redis objects to keep things organized.

### Why does version 2 change the API?

Redis Classy has been around for almost 4 years, and successfully used in production. While useful, the biggest pain point was the heavy dependency on class methods.

Normally, you would think models in the way you think of ActiveRecord:

```ruby
user = User.find(123)
user.name = 'kenn'
user.save
```

However, the most attractive feature of Redis is atomic operations, and fetch-modify-write is not the way we get the most out of Redis. Therefore, it was tempting to do something in one shot:

```ruby
# Redis Classy v1
RedisUser.set '123', 'kenn'
```

As almost all operations were done in one shot, it seemed awkward to do like:

```ruby
# Redis Classy v1 and v2
RedisUser.new('123').set('kenn')
```

Why would you instantiate an object if it will be immediately consumed in the same method chain?

But it turned out that having all methods at instance level was way more powerful, and cleaner.

### What's new:

* v1.2.0: Raise NoMethodError when commands are not found in redis-rb.
* v1.1.1: Raise exception when Redis::Classy.db is not assigned
* v1.1.0: Explicitly require all files
* v1.0.1: Relaxed version dependency on redis-namespace
* v1.0.0: Play nice with Mongoid

Synopsis
--------

With the vanilla `redis` gem, you've been doing this:

```ruby
redis = Redis.new
redis.set 'foo', 'bar'
redis.get 'foo'
 => "bar"
```

With the `redis-namespace` gem, you can add a prefix in the following manner:

```ruby
redis_ns = Redis::Namespace.new('ns', :redis => redis)
redis_ns['foo'] = 'bar'         # equivalent of => redis.set 'ns:foo', 'bar'
redis_ns['foo']                 # equivalent of => redis.get 'ns:foo'
 => "bar"
```

Now, with the `redis-classy` gem, you finally achieve a class-based encapsulation:

```ruby
class Something < RedisClassy
end

Something.on('foo').set('bar')     # equivalent of => redis.set 'Something:foo', 'bar'
Something.on('foo').get            # equivalent of => redis.get 'Something:foo'
 => "bar"

something = Something.new('foo')
something.set 'bar'
something.get
 => "bar"
```

Install
-------

    gem install redis-classy

Usage
-----

In Gemfile:

```ruby
gem 'redis-classy'
```

Register the Redis server: (e.g. in `config/initializers/redis_classy.rb` for Rails)

```ruby
RedisClassy.redis = Redis.new(:host => 'localhost')
```

Now you can write models that inherit `RedisClassy`, automatically prefixing keys with its class name.
You can use any Redis commands on the class, as they are eventually passed to the `redis` gem.

```ruby
class UniqueUser < RedisClassy
  def self.nuke
    self.keys.each{|key| self.del(key) }
  end
end

UniqueUser.sadd '2011-02-28', '123'
UniqueUser.sadd '2011-02-28', '456'
UniqueUser.sadd '2011-03-01', '789'

UniqueUser.smembers '2011-02-28'
 => ["123", "456"]

UniqueUser.keys
 => ["2011-02-28", "2011-03-01"]

UniqueUser.nuke
UniqueUser.keys
 => []
```

In most cases you may be just fine with class methods, but by creating an instance with a key, even further binding is possible.

```ruby
class Counter < RedisClassy
  def initialize(object)
    super("#{object.class.name}:#{object.id}")
  end
end

class Room < ActiveRecord::Base
end

@room = Room.create

counter = Counter.new(@room)
counter.key
 => "Room:123"

counter.incr
counter.incr
counter.get
 => "2"
```

You also have access to the non-namespaced, raw Redis instance via `RedisClassy`.

```ruby
RedisClassy.keys
 => ["UniqueUser:2011-02-28", "UniqueUser:2011-03-01", "Counter:Room:123"]

RedisClassy.keys 'UniqueUser:*'
 => ["UniqueUser:2011-02-28", "UniqueUser:2011-03-01"]

RedisClassy.multi do
  UniqueUser.sadd '2011-02-28', '123'
  UniqueUser.sadd '2011-02-28', '456'
end
```

Since the `redis` attribute is a class instance variable, you can dynamically assign different databases for each class.

```ruby
UniqueUser.redis = Redis::Namespace.new('UniqueUser', :redis => Redis.new(:host => 'another.host'))
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
