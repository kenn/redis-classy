# Upgrading from 1.x

`redis-classy` 2.0 has brought quite a few changes. Please read these points carefully.

Please post any implications we may have missed as a GitHub Issue or Pull Request.

* No redis commands are delegated at the class level. Always use instance methods or explicitly declare singleton.
  * `Something.set 'key', 'value'` is now `Something.on('key').set('value')`
* The base class `Redis::Classy` is now `RedisClassy`.
* `Redis::Classy.db = Redis.new` is now `RedisClassy.redis = Redis.new`.
