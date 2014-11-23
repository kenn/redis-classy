class RedisClassy
  class << self
    attr_accessor :redis

    def inherited(subclass)
      raise 'RedisClassy.redis is not assigned' unless RedisClassy.redis
      subclass.redis = Redis::Namespace.new(subclass.name, redis: RedisClassy.redis)
    end

    def singletons(*args)
      args.each do |key|
        define_singleton_method(key) do
          new key
        end
      end
    end

    def singleton
      @singleton = true
    end

    def keys(pattern = nil)
      redis.keys(pattern)
    end

    def on(key)
      new(key)
    end

    def method_missing(command, *args, &block)
      if @singleton
        new('singleton').send(command, *args, &block)
      else
        super
      end
    end
  end

  # Instance methods

  attr_accessor :key, :redis, :object

  def initialize(object)
    @redis = self.class.redis
    @object = object

    case object
    when String, Symbol, Integer
      @key = object.to_s
    else
      if object.respond_to?(:id)
        @key = object.id.to_s
      else
        raise ArgumentError, 'object must be a string, symbol, integer or respond to :id method'
      end
    end
  end

  KEYLESS_COMMANDS = [:multi, :pipelined, :exec, :eval]

  def method_missing(command, *args, &block)
    if @redis.respond_to?(command)
      case command
      when *KEYLESS_COMMANDS
        @redis.send(command, *args, &block)
      else
        @redis.send(command, @key, *args, &block)
      end
    else
      super
    end
  end
end
