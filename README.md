Redis Classy
============

Class-style namespace prefixing for Redis.

With Redis Classy, class names become the prefix part of the Redis keys.

```ruby
class Something < Redis::Classy
end

Something.set 'foo', 'bar'      # equivalent of => redis.set 'Something:foo', 'bar'
Something.get 'foo'             #               => redis.get 'Something:foo'
 => "bar"
```

This library contains only 30+ lines of code, yet powerful when you need better abstraction on Redis objects to keep things organized.

Requies the `redis-namespace` gem.

What's new:

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
redis_ns['foo'] = 'bar'      # equivalent of => redis.set 'ns:foo', 'bar'
```

Now, with the redis-classy gem, you could finally do:

```ruby
class Something < Redis::Classy
end

Something.set 'foo', 'bar'      # equivalent of => redis.set 'Prefix:foo', 'bar'
Something.get 'foo'
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

In config/initializers/redis_classy.rb:

```ruby
Redis::Classy.db = Redis.new
```

Now you can write models that inherit the Redis::Classy class, automatically prefixing keys with its class name.
You can use any Redis commands on the class, since they are simply passed to the Redis instance.

```ruby
class UniqueUser < Redis::Classy
  def self.nuke
    self.keys.each{|key| self.del(key) }
  end
end

UniqueUser.sadd '2011-02-28', @user_a.id
UniqueUser.sadd '2011-02-28', @user_b.id
UniqueUser.sadd '2011-03-01', @user_c.id

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
counter.incr
counter.incr
counter.get
 => "2"

counter.key
 => "Room:123"
```

You also have access to the non-namespaced, raw Redis instance via Redis::Classy

```ruby
Redis::Classy.keys 'UniqueUser:*'
 => ["UniqueUser:2011-02-28", "UniqueUser:2011-03-01"]

Redis::Classy.multi do
  UniqueUser.sadd '2011-02-28', @user_a.id
  UniqueUser.sadd '2011-02-28', @user_b.id
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
