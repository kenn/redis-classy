Redis Classy
============

Class-style namespace prefixing for Redis.

With Redis Classy, class names become the prefix part of the Redis keys.

```ruby
class Something < Redis::Classy
end

Something.set 'foo', 'bar'      # equivalent of => redis.set 'Something:foo', 'bar'
Something.get 'foo'             # equivalent of => redis.get 'Something:foo'
 => "bar"
```

All methods are delegated to the `redis-namespace` gems.

This library contains only 30+ lines of code, yet powerful when you need better abstraction on Redis objects to keep things organized.

### What's new:

* v1.0.1: Relaxed version dependency on redis-namespace
* v1.0.0: Play nice with Mongoid

Synopsis
--------

With the vanilla `redis` gem, you've been doing this:

```ruby
redis = Redis.new
redis.set 'foo', 'bar'
```

With the `redis-namespace` gem, you can add a prefix in the following manner:

```ruby
redis_ns = Redis::Namespace.new('ns', :redis => redis)
redis_ns['foo'] = 'bar'         # equivalent of => redis.set 'ns:foo', 'bar'
```

Now, with the `redis-classy` gem, you finally achieve a class-based encapsulation:

```ruby
class Something < Redis::Classy
end

Something.set 'foo', 'bar'      # equivalent of => redis.set 'Something:foo', 'bar'
Something.get 'foo'             # equivalent of => redis.get 'Something:foo'
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
Redis::Classy.db = Redis.new(:host => 'localhost')
```

Now you can write models that inherit `Redis::Classy`, automatically prefixing keys with its class name.
You can use any Redis commands on the class, as they are eventually passed to the `redis` gem.

```ruby
class UniqueUser < Redis::Classy
  def self.nuke
    self.keys.each{|key| self.del(key) }
  end
end

UniqueUser.sadd '2011-02-28', 123
UniqueUser.sadd '2011-02-28', 456
UniqueUser.sadd '2011-03-01', 789

UniqueUser.smembers '2011-02-28'
 => ["123", "456"]

UniqueUser.nuke
 => ["2011-02-28", "2011-03-01"]

UniqueUser.keys
 => []
```

In most cases you may be just fine with class methods, but by creating an instance with a key, even further binding is possible.

```ruby
class Counter < Redis::Classy
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

You also have access to the non-namespaced, raw Redis instance via `Redis::Classy`.

```ruby
Redis::Classy.keys
 => ["UniqueUser:2011-02-28", "UniqueUser:2011-03-01", "Counter:Room:123"]

Redis::Classy.keys 'UniqueUser:*'
 => ["UniqueUser:2011-02-28", "UniqueUser:2011-03-01"]

Redis::Classy.multi do
  UniqueUser.sadd '2011-02-28', 123
  UniqueUser.sadd '2011-02-28', 456
end
```

Since the `db` attribute is a class instance variable, you can dynamically assign different databases for each class.

```ruby
UniqueUser.db = Redis::Namespace.new('UniqueUser', :redis => Redis.new(:host => 'another.host'))
```

Reference
---------

Dependency:

* <https://github.com/ezmobius/redis-rb>
* <https://github.com/defunkt/redis-namespace>

Use case:

* <https://github.com/kenn/redis-mutex>
