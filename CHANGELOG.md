## 2.2.0 2014-11-23

  * Class-level commands are forwarded again

## 2.1.0 2014-11-23

  * Lazy connection loading

## 2.0.0 2014-11-23

  * New feature: `singletons` to support predefined keys
  * New feature: `singleton` to deal with singleton data
  * New feature: `on` as a syntactic sugar for `new`
  * New feature: `multi`, `pipelined`, `exec` and `eval` are available as instance methods
  * No redis commands are delegated at the class level. Always use instance methods or explicitly declare singleton.
  * The base class `Redis::Classy` is now `RedisClassy`
  * `Redis::Classy.db = Redis.new` is now `RedisClassy.redis = Redis.new`.

## 1.1.1

  * Raise exception when Redis::Classy.db is not assigned

## 1.1.0

  * Explicitly require all files

## 1.0.1

  * Relaxed version dependency on redis-namespace

## 1.0.0

  * Play nice with Mongoid
