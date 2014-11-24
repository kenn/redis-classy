# Upgrading from 1.x

`redis-classy` 2.0 has brought quite a few changes. Please read these points carefully.

Please post any implications we may have missed as a GitHub Issue or Pull Request.

* The base class `Redis::Classy` is now `RedisClassy`.
* `Redis::Classy.db = Redis.new` is now `RedisClassy.redis = Redis.new`.
